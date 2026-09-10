# frozen_string_literal: true

class OrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |_e|
    redirect_to cart_path, alert: t('flash.orders.error.not_found')
  end

  rescue_from ActiveRecord::RecordNotUnique do |_e|
    redirect_to cart_path, alert: t('flash.orders.error.duplicate_order_number')
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    redirect_to cart_path, alert: e.record.errors.full_messages.join(', ')
  end

  # 在庫チェック通過後に他の注文で在庫が減った場合、Sku側のバリデーションメッセージではなく
  # 購入者向けの文言を出すため、専用の例外を捕まえる
  rescue_from Sku::InsufficientStockError do |_e|
    redirect_to cart_path, alert: t('flash.orders.error.out_of_stock')
  end

  before_action :set_cart, only: %i[new create]
  before_action :ensure_cart_present, only: %i[create]
  before_action :ensure_stock_available, only: %i[new create]

  def new
    @order = Order.new
    @breadcrumbs = [{ name: 'カート', path: cart_path }, { name: '注文確認' }]
  end

  def create
    order = create_order_from_cart(@cart)
    session.delete(:cart_id)

    redirect_to order_path(order.order_number)
  end

  def show
    @order = Order.find_by!(order_number: params[:id])
  end

  private

  def create_order_from_cart(cart)
    order = nil
    ActiveRecord::Base.transaction do
      decrement_sku_stock_quantity(cart)
      order = build_order_with_items(cart)
      confirm_payment!(order)
      cart.destroy
    end
    order
  end

  def decrement_sku_stock_quantity(cart)
    ordered_skus_with_quantity(cart).each { |sku, quantity| sku.decrement_stock!(quantity) }
  end

  # 行ロックは外側のtransactionが終わるまで解放されないため、同時注文でロックの取得順が
  # 交差するとデッドロックになる。全リクエストで順序を揃えるためSKUのid順に整列する
  def ordered_skus_with_quantity(cart)
    pairs = cart.cart_items.map do |item|
      sku = item.product&.sku
      # 在庫チェック通過後にSKUが消えた場合も、在庫不足と同じ扱いで注文を止める
      raise Sku::InsufficientStockError if sku.nil?

      [sku, item.quantity]
    end
    pairs.sort_by { |sku, _quantity| sku.id }
  end

  def build_order_with_items(cart)
    order = Order.create!(order_params.merge(payment_status: 'pending'))
    cart.cart_items.each do |item|
      order.order_items.create!(product_id: item.product_id, quantity: item.quantity, price: item.unit_price)
    end
    order
  end

  # TODO: 決済APIと連携したら、実際の決済結果に応じてpaid/failedを設定する
  def confirm_payment!(order)
    order.update!(payment_status: 'paid')
  end

  def order_params
    params.require(:order).permit(:shipping_postal_code, :shipping_prefecture, :shipping_city, :shipping_address_line)
  end

  def set_cart
    @cart = existing_cart
  end

  def ensure_cart_present
    return if @cart.present? && @cart.cart_items.any?

    redirect_to cart_path, alert: t('flash.orders.error.empty_cart')
  end

  # newは空カートでも「カートは空です」を表示する仕様なので、ここでは空カートを素通りさせる
  def ensure_stock_available
    return if @cart.nil? || @cart.cart_items.empty?
    return if @cart.cart_items.all? { |item| item.product&.sku&.enough_stock?(item.quantity) }

    redirect_to cart_path, alert: t('flash.orders.error.out_of_stock')
  end
end
