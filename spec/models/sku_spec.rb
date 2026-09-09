# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sku, type: :model do
  let!(:store) { Store.create!(name: 'SKU店舗', code: 'SKU-STORE') }
  let!(:product) { store.products.create!(name: 'SKU商品', published: true) }

  def build_sku(attrs = {})
    Sku.new({
      product: product,
      code: 'SKU-001',
      price: 1000,
      stock_quantity: 1
    }.merge(attrs))
  end

  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      expect(build_sku).to be_valid
    end

    it 'codeがない場合は無効' do
      expect(build_sku(code: nil)).not_to be_valid
    end

    it 'codeが重複する場合は無効' do
      product.create_sku!(code: 'SKU-001', price: 1000, stock_quantity: 1)
      other_product = store.products.create!(name: '別商品', published: true)
      sku = Sku.new(product: other_product, code: 'SKU-001', price: 500, stock_quantity: 1)
      expect(sku).not_to be_valid
    end

    it 'priceがない場合は無効' do
      expect(build_sku(price: nil)).not_to be_valid
    end

    it 'priceが負の場合は無効' do
      expect(build_sku(price: -1)).not_to be_valid
    end

    it 'priceが整数でない場合は無効' do
      expect(build_sku(price: 1.5)).not_to be_valid
    end

    it 'stock_quantityがない場合は無効' do
      expect(build_sku(stock_quantity: nil)).not_to be_valid
    end

    it 'stock_quantityが負の場合は無効' do
      expect(build_sku(stock_quantity: -1)).not_to be_valid
    end

    it '1 product に対して複数 SKU は無効' do
      product.create_sku!(code: 'SKU-001', price: 1000, stock_quantity: 1)
      sku = Sku.new(product: product, code: 'SKU-002', price: 500, stock_quantity: 1)
      expect(sku).not_to be_valid
    end
  end

  describe '#in_stock?' do
    it '在庫がある場合は true' do
      sku = product.create_sku!(code: 'SKU-STOCK', price: 1000, stock_quantity: 1)
      expect(sku.in_stock?).to eq(true)
    end

    it '在庫が0の場合は false' do
      sku = product.create_sku!(code: 'SKU-EMPTY', price: 1000, stock_quantity: 0)
      expect(sku.in_stock?).to eq(false)
    end
  end
end
