# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    before_action :set_store
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @q_name = params[:name].to_s.strip
      @q_sku_code = params[:sku_code].to_s.strip
      @q_published = params[:published].presence || 'all'
      @q_price_min = params[:price_min].to_s.strip
      @q_price_max = params[:price_max].to_s.strip

      @searched = @q_name.present? || @q_sku_code.present? ||  # ユーザー側のみ
                  @q_price_min.present? ||
                  @q_price_max.present? ||
                  @q_published != 'all'

      if @searched
        products = @store.products.includes(:sku)
        products = products.where('products.name LIKE ?', "%#{Product.sanitize_sql_like(@q_name)}%") if @q_name.present?
        products = products.where(published: true) if @q_published == 'true'
        products = products.where(published: false) if @q_published == 'false'
        if @q_sku_code.present? || @q_price_min.present? || @q_price_max.present?
          products = products.joins(:sku)
          if @q_sku_code.present?
            products = products.where('skus.code LIKE ?',
                                      "%#{Sku.sanitize_sql_like(@q_sku_code)}%")
          end
          products = products.where('skus.price >= ?', @q_price_min.to_i) if @q_price_min.present?
          products = products.where('skus.price <= ?', @q_price_max.to_i) if @q_price_max.present?
        end
        @products = products
      else
        @products = Product.none
      end
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
  end
end
