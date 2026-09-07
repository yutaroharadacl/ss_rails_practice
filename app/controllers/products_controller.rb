class ProductsController < ApplicationController
  def index
    @products = Product.where(published: true).includes(:sku, :store)
  end
end
