# frozen_string_literal: true

class OrdersController < ApplicationController

  def new
    @cart = existing_cart
    @order = Order.new
  end

  def create
    cart = existing_cart
    if cart.nil? || cart.cart_items.empty?
      redirect_to cart_path
      return
    end

    order = nil
    ActiveRecord::Base.transaction do
      order = Order.create!(order_params.merge(payment_status: 'pending'))
      cart.cart_items.each do |item|
        # TODO: productができたらpriceを入れる
        order.order_items.create!(product_id: item.product_id, quantity: item.quantity, price: 1000)
      end
      order.update!(payment_status: 'paid')
      cart.destroy
    end
    session.delete(:cart_id)

    redirect_to order_path(order)
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:shipping_postal_code, :shipping_prefecture, :shipping_city, :shipping_address_line)
  end
end
