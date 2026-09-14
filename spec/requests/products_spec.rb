# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let!(:store) { Store.create!(name: 'テスト店舗', code: 'TEST') }

  def create_product!(name:, code:, published: true, price: 1000, stock_quantity: 10)
    product = store.products.build(name: name, description: '説明', published: published)
    product.build_sku(code: code, price: price, stock_quantity: stock_quantity)
    product.save!
    product
  end

  describe 'GET /products' do
    let!(:published_product) { create_product!(name: '公開りんご', code: 'SKU-PUB-1') }
    let!(:unpublished_product) { create_product!(name: '非公開バナナ', published: false, code: 'SKU-UNPUB-1') }

    context 'search パラメータがない場合' do
      it '案内メッセージを表示し、商品一覧テーブルは出ない' do
        get products_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('検索条件を指定して検索してください')
        expect(response.body).not_to include('公開りんご')
        expect(response.body).not_to include('<table')
      end
    end

    context 'search=1 の場合' do
      it '公開商品が表示され、非公開商品は表示されない' do
        get products_path, params: { search: 1 }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('公開りんご')
        expect(response.body).not_to include('非公開バナナ')
      end
    end

    context 'search=1 かつ name がある場合' do
      let!(:other_product) { create_product!(name: '公開みかん', code: 'SKU-PUB-2') }

      it '商品名の部分一致で絞り込める' do
        get products_path, params: { search: 1, q: { name_cont: 'りんご' } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('公開りんご')
        expect(response.body).not_to include('公開みかん')
      end
    end

    context 'ページネーション' do
      before do
        stub_const('ProductsController::PER_PAGE', 2)
        create_product!(name: '商品A', code: 'SKU-PAGE-A')
        create_product!(name: '商品B', code: 'SKU-PAGE-B')
        create_product!(name: '商品C', code: 'SKU-PAGE-C')
      end

      it 'page=2 では2ページ目の商品が出て、1ページ目の商品は出ない' do
        get products_path, params: { search: 1, q: { name_cont: '商品' }, page: 2 }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('商品C')
        expect(response.body).not_to include('商品A')
        expect(response.body).not_to include('商品B')
      end

      it 'search と検索条件を残した page 付き GET が成功する' do
        get products_path, params: { search: 1, q: { name_cont: '商品' }, page: 2 }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('2 / 2')
        expect(response.body).to include('商品C')
      end
    end

    context 'セール中の価格表示と定価検索' do
      include ActiveSupport::Testing::TimeHelpers

      let!(:sale_product) { create_product!(name: 'セールりんご', code: 'SKU-SALE-1', price: 1000) }

      before do
        sale_product.sku.update!(
          sale_price: 500,
          sale_starts_at: Time.zone.parse('2026-09-10 10:00:00'),
          sale_ends_at: Time.zone.parse('2026-09-10 18:00:00')
        )
      end

      it '定価と販売価格の両方が表示される' do
        travel_to Time.zone.parse('2026-09-10 12:00:00') do
          get products_path, params: { search: 1 }

          expect(response.body).to include('定価')
          expect(response.body).to include('販売価格')
          expect(response.body).to include('1,000円')
          expect(response.body).to include('500円')
        end
      end

      it '価格検索は定価で絞り込む（セール価格では絞り込まない）' do
        travel_to Time.zone.parse('2026-09-10 12:00:00') do
          get products_path, params: { search: 1, q: { sku_price_lteq: 600 } }
          expect(response.body).not_to include('セールりんご')

          get products_path, params: { search: 1, q: { sku_price_lteq: 1000 } }
          expect(response.body).to include('セールりんご')
        end
      end
    end
  end
end
