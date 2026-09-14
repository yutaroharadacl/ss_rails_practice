# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let!(:store) { Store.create!(name: '店舗', code: 'CI-STORE') }
  let!(:product) { create_product!(store: store, name: 'りんご', code: 'CI-APPLE') }

  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      item = CartItem.new(product_id: product.id, quantity: 1, cart: Cart.create!)
      expect(item).to be_valid
    end

    it 'product_idがない場合は無効' do
      item = CartItem.new(product_id: nil, quantity: 1, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityがない場合は無効' do
      item = CartItem.new(product_id: product.id, quantity: nil, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが0以下の場合は無効' do
      item = CartItem.new(product_id: product.id, quantity: 0, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが数値でない場合は無効' do
      item = CartItem.new(product_id: product.id, quantity: 'a', cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが整数でない場合は無効' do
      item = CartItem.new(product_id: product.id, quantity: 1.5, cart: Cart.create!)
      expect(item).not_to be_valid
    end
  end

  describe '#unit_price' do
    include ActiveSupport::Testing::TimeHelpers

    it 'セール期間外は定価を返す' do
      item = CartItem.new(product: product, quantity: 1)
      expect(item.unit_price).to eq(1000)
    end

    it 'セール期間内はセール価格を返す' do
      product.sku.update!(
        sale_price: 800,
        sale_starts_at: Time.zone.parse('2026-09-10 10:00:00'),
        sale_ends_at: Time.zone.parse('2026-09-10 18:00:00')
      )
      item = CartItem.new(product: product, quantity: 1)

      travel_to Time.zone.parse('2026-09-10 12:00:00') do
        expect(item.unit_price).to eq(800)
      end
    end
  end
end
