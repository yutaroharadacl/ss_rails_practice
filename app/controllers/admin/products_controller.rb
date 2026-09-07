class Admin::ProductsController < ApplicationController
  before_action :set_store
  before_action :set_product, only: %i[show edit update destroy]


  def index
    @products = @store.products.includes(:sku)
  end

  def show
    @product = @store.products.find(params[:id])

  end

  def new
    @product = @store.products.build
    @product.build_sku
  end

  def create
    @product = @store.products.build(product_params)
    if @product.save
      redirect_to admin_store_product_path(@store, @product)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_store_product_path(@store, @product)
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_store_products_path(@store)
  end

  private
  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :published,
      sku_attributes: %i[id code price stock_quantity]
    )
  end

end
