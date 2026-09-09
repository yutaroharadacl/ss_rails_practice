# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    cart = existing_cart
    @cart = cart && Cart.includes(cart_items: { product: :sku }).find_by(id: cart.id)
  end
end
