# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe '#subtotal' do
    it '単価*数量を返すこと' do
      item = OrderItem.new(price: 300, quantity: 2)
      expect(item.subtotal).to eq(600)
    end
  end

  describe '単価の補完' do
    include ActiveSupport::Testing::TimeHelpers

    let!(:store) { Store.create!(name: '店舗', code: 'OI-STORE') }
    let!(:product) { create_product!(store: store, name: 'りんご', code: 'OI-APPLE') }
    let!(:order) { Order.create!(status: 'new') }

    it 'price未設定ならSKUの販売単価が入る' do
      item = order.order_items.build(product: product, quantity: 1)
      item.valid?
      expect(item.price).to eq(1000)
    end

    it 'セール期間内ならセール価格が入る' do
      product.sku.update!(
        sale_price: 800,
        sale_starts_at: Time.zone.parse('2026-09-10 10:00:00'),
        sale_ends_at: Time.zone.parse('2026-09-10 18:00:00')
      )

      travel_to Time.zone.parse('2026-09-10 12:00:00') do
        item = order.order_items.build(product: product, quantity: 1)
        item.valid?
        expect(item.price).to eq(800)
      end
    end
  end
end
