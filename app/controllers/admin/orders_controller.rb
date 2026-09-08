# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    # アクションを実行する前に実行する関数
    before_action :set_order, only: %i[show update]
    before_action :check_order_completed, only: [:update]

    def index
      @orders = Order.all
    end

    def show
      @breadcrumbs = [{ name: '受注管理', path: admin_orders_path }, { name: '受注詳細' }]
    end

    def update
      if @order.update(order_params)
        redirect_to admin_order_path(@order, anchor: params[:tab])
      else
        redirect_to admin_order_path(@order, anchor: params[:tab]), alert: @order.errors.full_messages.join(', ')
      end
    end

    private

    def order_params
      # _destroyは、Railsが「このネストしたレコードを削除対象とする」ために内部的に使う特別なキー名
      params.require(:order).permit(:status, :shipping_postal_code, :shipping_prefecture, :shipping_city,
                                    :shipping_address_line, order_items_attributes: %i[id price quantity _destroy])
    end

    def set_order
      @order = Order.find(params[:id])
    end

    # 編集不可（complete）の場合は弾く
    def check_order_completed
      return if @order.editable?

      redirect_to admin_order_path(@order, anchor: params[:tab]), alert: '完了済みの受注は編集できません'
    end
  end
end
