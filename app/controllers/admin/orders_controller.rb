# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to admin_orders_path, alert: t('flash.admin.orders.error.not_found')
    end

    # id_eqなどに桁あふれする値を渡された場合の型キャストエラー対策
    rescue_from ActiveModel::RangeError do |_e|
      redirect_to admin_orders_path, alert: t('flash.admin.orders.error.invalid_search')
    end

    rescue_from Sku::InsufficientStockError do |_e|
      redirect_to admin_order_path(@order, anchor: params[:tab]), alert: t('flash.admin.orders.error.out_of_stock')
    end

    # アクションを実行する前に実行する関数
    before_action :set_order, only: %i[show update]
    before_action :check_order_completed, only: [:update]

    def index
      # ハッシュを渡して検索オブジェクトを作成する
      # @q.result で検索オブジェクトから結果を取得できる
      @q = Order.ransack(params[:q])
      @searched = params[:q].present?
      # distinct: true は、検索条件によっては内部でJOINが発生して同じ受注が複数行返ってくることがあるので、それを防ぐため
      @orders = @q.result(distinct: true).includes(:order_items, :user)
    end

    def show
      @breadcrumbs = [{ name: '受注管理', path: admin_orders_path }, { name: '受注詳細' }]
    end

    def update
      if update_order_and_adjust_stock
        redirect_to admin_order_path(@order, anchor: params[:tab]), notice: t('flash.admin.orders.update.notice')
      else
        redirect_to admin_order_path(@order, anchor: params[:tab]), alert: @order.errors.full_messages.join(', ')
      end
    end

    private

    def order_params
      # _destroyは、Railsが「このネストしたレコードを削除対象とする」ために内部的に使う特別なキー名
      params.require(:order).permit(:status, :shipping_postal_code, :shipping_prefecture, :shipping_city,
                                    :shipping_address_line, :desired_delivery_date,
                                    order_items_attributes: %i[id price quantity _destroy])
    end

    def set_order
      @order = Order.includes(:user, order_items: { product: :sku }).find(params[:id])
    end

    # 編集不可（complete）の場合は弾く
    def check_order_completed
      return if @order.editable?

      redirect_to admin_order_path(@order, anchor: params[:tab]), alert: t('flash.admin.orders.error.not_editable')
    end

    def update_order_and_adjust_stock
      items_with_old_quantity = @order.order_items.map { |item| [item, item.quantity] }

      ActiveRecord::Base.transaction do
        next false unless @order.update(order_params)

        # update後なのでここでのitemはすでにquantityの値が変更されている
        sorted_items_with_old_quantity(items_with_old_quantity).each do |item, old_quantity|
          adjust_stock_for_order_item(item, old_quantity)
        end

        true
      end
    end

    # 行ロックの取得順をSKUのid順に揃える（順序が交差すると同時更新でデッドロックになるため）
    def sorted_items_with_old_quantity(items_with_old_quantity)
      items_with_old_quantity.sort_by { |item, _old_quantity| item.product&.sku&.id || 0 }
    end

    # 商品が削除済みでSKUが無い明細は、在庫と紐付けようが無いのでスキップする
    def adjust_stock_for_order_item(item, old_quantity)
      sku = item.product&.sku
      return if sku.nil?

      if item.destroyed?
        sku.increment_stock!(old_quantity)
      else
        adjust_sku_stock_by_delta(sku, item.quantity - old_quantity)
      end
    end

    def adjust_sku_stock_by_delta(sku, delta)
      return if delta.zero?

      if delta.positive?
        sku.decrement_stock!(delta)
      else
        sku.increment_stock!(-delta)
      end
    end
  end
end
