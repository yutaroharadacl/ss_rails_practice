# frozen_string_literal: true

class ProductsController < ApplicationController
  PER_PAGE = 20

  def index
    # 検索フォーム送信（またはページネーションで search=1 が残っている）かどうか
    @submitted = params[:search].present?

    base = Product.where(published: true).includes(:sku, :store)
    @q = base.ransack(search_params)

    scope = @submitted ? @q.result(distinct: true) : Product.none

    @page = [params[:page].to_i, 1].max
    @total_count = scope.count
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max
    @page = @total_pages if @page > @total_pages
    @products = scope.order(:id).limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end

  private

  def search_params
    params.fetch(:q, {}).permit(
      :name_cont, :sku_code_cont, :store_name_cont, :sku_price_gteq, :sku_price_lteq
    )
  end
end
