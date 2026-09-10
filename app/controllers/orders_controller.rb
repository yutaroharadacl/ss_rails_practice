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

  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = existing_cart
    @order = Order.new
    @breadcrumbs = [{ name: 'カート', path: cart_path }, { name: '注文確認' }]
  end

  def create
    cart = existing_cart
    if cart.nil? || cart.cart_items.empty?
      redirect_to cart_path, alert: t('flash.orders.error.empty_cart')
      return
    end

    order = create_order_from_cart(cart)
    session.delete(:cart_id)

    redirect_to order_path(order.order_number)
  end

  def show
    @order = current_user.orders.find_by!(order_number: params[:id])
  end

  private

  def create_order_from_cart(cart)
    order = nil
    ActiveRecord::Base.transaction do
      order = build_order_with_items(cart)
      confirm_payment!(order)
      cart.destroy
    end
    order
  end

  def build_order_with_items(cart)
    order = Order.create!(order_params.merge(payment_status: 'pending',user: current_user))
    cart.cart_items.each do |item|
      # TODO: productができたらpriceを入れる
      order.order_items.create!(product_id: item.product_id, quantity: item.quantity, price: 1000)
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
end
