# frozen_string_literal: true

module Admin
  class OrderItemsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to admin_orders_path, alert: t('flash.admin.orders.error.not_found')
    end

    # ransackに桁あふれする値を渡された場合の型キャストエラー対策（admin/orders_controllerと同じ理由）
    rescue_from ActiveModel::RangeError do |_e|
      if @order
        redirect_to items_tab_path, alert: t('flash.admin.order_items.error.invalid_search')
      else
        redirect_to admin_orders_path, alert: t('flash.admin.orders.error.invalid_search')
      end
    end

    before_action :set_order
    before_action :check_order_completed

    def new
      @q = @order.selectable_products.ransack(params[:q])
      @products = @q.result
    end

    def create
      # 単価はOrderItemのbefore_validationがSKUから補う（フォームの値は受け取らない）
      order_item = @order.order_items.build(order_item_params)
      if order_item.save
        redirect_to items_tab_path(reopen: true), notice: t('flash.admin.order_items.create.notice')
      else
        redirect_to items_tab_path(reopen: true), alert: order_item.errors.full_messages.join(', ')
      end
    end

    private

    def order_item_params
      params.require(:order_item).permit(:product_id, :quantity)
    end

    # 追加後もモーダルの検索条件を引き継げるよう、絞り込み条件だけを取り出す
    def search_params
      return {} if params[:q].blank?

      params.require(:q).permit(:name_cont, :sku_code_cont).to_h.reject { |_key, value| value.blank? }
    end

    # 受注商品管理タブへの戻り先。reopen: trueなら商品追加モーダルを開いた状態で戻る。
    def items_tab_path(reopen: false)
      options = { anchor: 'tab-items' }
      options.merge!(open_modal: 1, q: search_params.presence) if reopen
      admin_order_path(@order, options.compact)
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    def check_order_completed
      return if @order.editable?

      redirect_to items_tab_path, alert: t('flash.admin.orders.error.not_editable')
    end
  end
end
