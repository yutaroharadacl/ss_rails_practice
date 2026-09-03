# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    # アクションを実行する前に実行する関数
    before_action :set_order, only: %i[show update]
    before_action :check_order_completed, only: [:update]

    def index
      @orders = Order.all
    end

    def show; end

    def update
      if @order.update(order_params)
        redirect_to admin_order_path(@order, tab: params[:tab])
      else
        redirect_to admin_order_path(@order, tab: params[:tab]), alert: @order.errors.full_messages.join(', ')
      end
    end

    private

    def order_params
      # _destroyは、Railsが「このネストしたレコードを削除対象とする」ために内部的に使う特別なキー名
      params.require(:order).permit(:status, order_items_attributes: %i[id price quantity _destroy])
    end

    def set_order
      @order = Order.find(params[:id])
    end

    # sutatusがcompleteの場合は編集させない
    def check_order_completed
      return unless @order.status == 'complete'

      redirect_to admin_order_path(@order), alert: '完了済みの受注は編集できません'
    end
  end
end
