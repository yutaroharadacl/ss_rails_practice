# frozen_string_literal: true

module Admin
  class OrderItemsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to admin_orders_path, alert: t('flash.admin.orders.error.not_found')
    end

    rescue_from ActiveRecord::RecordNotUnique do |_e|
      redirect_to items_tab_path(reopen: true), alert: t('flash.admin.order_items.error.duplicate')
    end

    rescue_from Sku::InsufficientStockError do |_e|
      redirect_to items_tab_path(reopen: true), alert: t('flash.admin.order_items.error.out_of_stock')
    end

    before_action :set_order
    before_action :check_order_completed

    def new
      # createと同じ許可リストを使い、UIに無い述語（sku_price_eqなど）は受け付けない
      @q = @order.selectable_products.ransack(search_params)
      @products = @q.result
      # モーダル内の差し替え専用。直接GETされた場合は406を返す（new.html.haml は無い）
      respond_to(&:js)
    end

    def create
      # 単価はOrderItemのbefore_validationがSKUから補う（フォームの値は受け取らない）
      order_item = @order.order_items.build(order_item_params)
      if save_order_item_and_decrement_stock(order_item)
        redirect_to items_tab_path(reopen: true), notice: t('flash.admin.order_items.create.notice')
      else
        redirect_to items_tab_path(reopen: true), alert: order_item.errors.full_messages.join(', ')
      end
    end

    private

    # order_itemの保存と在庫減算を1つのtransactionにまとめ、在庫不足時は
    # order_itemの保存も含めてロールバックする
    def save_order_item_and_decrement_stock(order_item)
      ActiveRecord::Base.transaction do
        next false unless order_item.save

        order_item.product.sku.decrement_stock!(order_item.quantity)
        true
      end
    end

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
