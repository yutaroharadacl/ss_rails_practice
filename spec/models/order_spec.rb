# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:store) { Store.create!(name: '店舗', code: 'STORE') }
  let!(:product1) { create_product!(store: store, name: 'りんご', code: 'APPLE', sku_attributes: { price: 500 }) }
  let!(:product2) { create_product!(store: store, name: 'みかん', code: 'ORANGE', sku_attributes: { price: 300 }) }

  describe 'statusのバリデーション' do
    it 'new もしくは complete であれば有効' do
      expect(Order.new(status: 'new')).to be_valid
      expect(Order.new(status: 'complete')).to be_valid
    end

    it 'それ以外の場合は無効' do
      expect(Order.new(status: 'test')).not_to be_valid
    end
  end

  describe '#subtotal' do
    it 'すべてのアイテムの小計が出力されること' do
      order = Order.create!(status: 'new')
      order.order_items.create!(product_id: product1.id, quantity: 2, price: 500)
      order.order_items.create!(product_id: product2.id, quantity: 1, price: 300)
      expect(order.subtotal).to eq(1300)
    end
  end

  describe '#tax' do
    it '消費税の計算がされること' do
      order = Order.create!(status: 'new')
      order.order_items.create!(product_id: product1.id, quantity: 2, price: 500)
      order.order_items.create!(product_id: product2.id, quantity: 1, price: 300)
      expect(order.tax).to eq(130)
    end
  end

  describe '#total' do
    it '小計と消費税の合計が出力されること' do
      order = Order.create!(status: 'new')
      order.order_items.create!(product_id: product1.id, quantity: 2, price: 500)
      order.order_items.create!(product_id: product2.id, quantity: 1, price: 300)
      expect(order.total).to eq(1430)
    end
  end
end
