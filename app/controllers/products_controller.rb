class ProductsController < ApplicationController
  PER_PAGE = 20

  def index
    @q_name = params[:name].to_s.strip
    @q_sku_code = params[:sku_code].to_s.strip
    @q_store_name = params[:store_name].to_s.strip
    @q_price_min = params[:price_min].to_s.strip
    @q_price_max = params[:price_max].to_s.strip

    # 検索フォーム送信（またはページネーションで search=1 が残っている）かどうか
    @submitted = params[:search].present?

    if @submitted
      scope = Product.where(published: true).includes(:sku, :store)

      scope = scope.where('products.name LIKE ?', "%#{Product.sanitize_sql_like(@q_name)}%") if @q_name.present?

      if @q_store_name.present?
        scope = scope.joins(:store).where('stores.name LIKE ?', "%#{Store.sanitize_sql_like(@q_store_name)}%")
      end

      if @q_sku_code.present? || @q_price_min.present? || @q_price_max.present?
        scope = scope.joins(:sku)
        scope = scope.where('skus.code LIKE ?', "%#{Sku.sanitize_sql_like(@q_sku_code)}%") if @q_sku_code.present?
        scope = scope.where('skus.price >= ?', @q_price_min.to_i) if @q_price_min.present?
        scope = scope.where('skus.price <= ?', @q_price_max.to_i) if @q_price_max.present?
      end
    else
      scope = Product.none
    end

    @page = [params[:page].to_i, 1].max
    @total_count = scope.count
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max
    @page = @total_pages if @page > @total_pages
    @products = scope.order(:id).limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end
end
