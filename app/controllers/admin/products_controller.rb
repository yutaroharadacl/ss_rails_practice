# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    before_action :set_store
    before_action :set_product, only: %i[show edit update destroy]
    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to products_path, alert: t('flash.admin.products.error.not_found')
    end
  

    def index
      q_params = search_params
      @searched = q_params.values.any?(&:present?)
    
      @q = @store.products.includes(:sku).ransack(q_params)
      @products = @searched ? @q.result(distinct: true) : Product.none
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

    def edit; end

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
    
    def search_params
      params.fetch(:q, {}).permit(
        :name_cont, :sku_code_cont, :published_eq, :sku_price_gteq, :sku_price_lteq
      )
    end
  end
end
