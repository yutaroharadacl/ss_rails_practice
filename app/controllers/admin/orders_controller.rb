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

    # アクションを実行する前に実行する関数
    before_action :set_order, only: %i[show update]
    before_action :check_order_completed, only: [:update]

    def index
      # ハッシュを渡して検索オブジェクトを作成する
      # @q.result で検索オブジェクトから結果を取得できる
      @q = Order.ransack(params[:q])
      @searched = params[:q].present?
      # distinct: true は、検索条件によっては内部でJOINが発生して同じ受注が複数行返ってくることがあるので、それを防ぐため
      @orders = @q.result(distinct: true).includes(:order_items)
    end

    def show
      @breadcrumbs = [{ name: '受注管理', path: admin_orders_path }, { name: '受注詳細' }]
    end

    def update
      if @order.update(order_params)
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
      @order = Order.find(params[:id])
    end

    # 編集不可（complete）の場合は弾く
    def check_order_completed
      return if @order.editable?

      redirect_to admin_order_path(@order, anchor: params[:tab]), alert: t('flash.admin.orders.error.not_editable')
    end
  end
end
