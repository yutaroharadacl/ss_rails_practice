# frozen_string_literal: true

module Admin
  class OrderItemsController < ApplicationController
    # 受注（set_order）と商品（create）のどちらのfindで発生した例外かをe.modelで見分ける。
    # 受注が無い場合は詳細画面を描けないので一覧へ、商品が無い場合は受注商品管理タブへ戻す。
    rescue_from ActiveRecord::RecordNotFound do |e|
      if e.model == 'Product'
        redirect_to admin_order_path(@order, anchor: 'tab-items'),
                    alert: t('flash.admin.order_items.error.not_found')
      else
        redirect_to admin_orders_path, alert: t('flash.admin.orders.error.not_found')
      end
    end

    before_action :set_order
    before_action :check_order_completed

    def new
      @q = @order.selectable_products.ransack(params[:q])
      @products = @q.result
    end

    def create
      order_item = @order.order_items.build(order_item_params)
      product = Product.find(order_item_params[:product_id])
      order_item.price = product.sku.price
      redirect_after_save(order_item)
    end

    private

    def order_item_params
      params.require(:order_item).permit(:product_id, :quantity)
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    def check_order_completed
      return if @order.editable?

      redirect_to admin_order_path(@order, anchor: 'tab-items'), alert: t('flash.admin.orders.error.not_editable')
    end

    def redirect_after_save(order_item)
      if order_item.save
        redirect_to admin_order_path(@order, anchor: 'tab-items'), notice: t('flash.admin.order_items.create.notice')
      else
        redirect_to admin_order_path(@order, anchor: 'tab-items'), alert: order_item.errors.full_messages.join(', ')
      end
    end
  end
end
