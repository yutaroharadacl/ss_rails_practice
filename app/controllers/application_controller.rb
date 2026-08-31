# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_cart

  private

  def current_cart
    @current_cart ||= find_current_cart
  end

  def find_current_cart
    # セッションに保存されているか確認
    cart = Cart.find_by(id: session[:cart_id])
    return cart if cart

    # なければ新しく作成してセッションに保存
    new_cart = Cart.create!
    session[:cart_id] = new_cart.id
    new_cart
  end
end
