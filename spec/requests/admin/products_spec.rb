# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Products', type: :request do
  let!(:store) { Store.create!(name: '管理店舗', code: 'ADMIN') }
  let!(:other_store) { Store.create!(name: '別店舗', code: 'OTHER') }

  def create_product!(store:, name:, code:, published: true, price: 1000, stock_quantity: 10)
    product = store.products.create!(name: name, description: '説明', published: published)
    product.create_sku!(code: code, price: price, stock_quantity: stock_quantity)
    product
  end

  let!(:product) { create_product!(store: store, name: '管理りんご', code: 'ADM-APPLE') }
  let!(:unpublished_product) do
    create_product!(store: store, name: '管理バナナ', published: false, code: 'ADM-BANANA')
  end
  let!(:other_store_product) do
    create_product!(store: other_store, name: '別店舗りんご', code: 'OTH-APPLE')
  end

  describe 'GET /admin/stores/:store_id/products' do
    context '検索条件がない場合' do
      it '案内メッセージを表示し、一覧には商品が出ない' do
        get admin_store_products_path(store)
        expect(response).to have_http_status(:success)
        expect(response.body).to include('検索条件を指定して検索してください')
        expect(response.body).not_to include('管理りんご')
        expect(response.body).not_to include('<table')
      end
    end

    context 'name 条件がある場合' do
      it '該当する店舗の商品が表示される' do
        get admin_store_products_path(store), params: { q: { name_cont: 'りんご' } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('管理りんご')
        expect(response.body).not_to include('管理バナナ')
        expect(response.body).not_to include('別店舗りんご')
      end
    end

    context 'published フィルタ' do
      it 'published=true で公開商品のみ表示される' do
        get admin_store_products_path(store), params: { q: { published_eq: true } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('管理りんご')
        expect(response.body).not_to include('管理バナナ')
      end

      it 'published=false で非公開商品のみ表示される' do
        get admin_store_products_path(store), params: { q: { published_eq: false } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('管理バナナ')
        expect(response.body).not_to include('管理りんご')
      end
    end
  end

  describe 'GET /admin/stores/:store_id/products/:id' do
    it '詳細が正常に取得できる' do
      get admin_store_product_path(store, product)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('管理りんご')
      expect(response.body).to include('ADM-APPLE')
    end
  end

  describe 'GET /admin/stores/:store_id/products/new' do
    it '新規登録画面が表示される' do
      get new_admin_store_product_path(store)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('商品の新規登録')
    end
  end

  describe 'POST /admin/stores/:store_id/products' do
    it '商品とSKUを作成できる' do
      expect do
        post admin_store_products_path(store), params: {
          product: {
            name: '新規商品',
            description: '新規の説明',
            published: '1',
            sku_attributes: {
              code: 'ADM-NEW-1',
              price: 1500,
              stock_quantity: 3
            }
          }
        }
      end.to change(Product, :count).by(1).and change(Sku, :count).by(1)

      created = store.products.find_by!(name: '新規商品')
      expect(response).to redirect_to(admin_store_product_path(store, created))
      expect(created.sku.code).to eq('ADM-NEW-1')
      expect(created.sku.price).to eq(1500)
      expect(created.published).to eq(true)
    end
  end
end
