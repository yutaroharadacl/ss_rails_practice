# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = existing_cart
  end
end
