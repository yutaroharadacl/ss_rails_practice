# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  let!(:store) { Store.create!(name: '商品店舗', code: 'PRODUCT-STORE') }

  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      product = store.products.build(name: 'テスト商品', published: true)
      product.build_sku(code: 'TEST-001', price: 1000, stock_quantity: 10)
      expect(product).to be_valid
    end

    it 'nameがない場合は無効' do
      product = store.products.build(name: nil, published: true)
      expect(product).not_to be_valid
    end

    it 'publishedがtrue/false以外の場合は無効' do
      product = store.products.build(name: 'テスト商品', published: nil)
      expect(product).not_to be_valid
    end
  end
end
