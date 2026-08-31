# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = current_cart
  end
end
