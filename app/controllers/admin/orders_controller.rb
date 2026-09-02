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
      @order.status = order_params[:status]
      if @order.save
        redirect_back fallback_location: admin_order_path(@order)
      else
        redirect_back fallback_location: admin_order_path(@order), alert: @order.errors.full_messages.join(', ')
      end
    end

    private

    def order_params
      params.require(:order).permit(:status)
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
