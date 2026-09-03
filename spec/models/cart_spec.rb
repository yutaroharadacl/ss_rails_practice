# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'cartを削除' do
    it 'cartを削除すると、そのcartに属するcart_itemsも削除される' do
      cart = Cart.create!
      cart.cart_items.create!(product_id: 1, quantity: 1)
      expect { cart.destroy! }.to change(CartItem, :count).by(-1)
    end
  end

  describe 'total_price' do
    it 'cart_itemが1件、数量も1時、計算結果が正しいこと' do
      cart = Cart.create!
      cart.cart_items.create!(product_id: 1, quantity: 1)
      expect(cart.total_price).to eq(BigDecimal('1100'))
    end

    it 'cart_itemが1件、数量が2の時、計算結果が正しいこと' do
      cart = Cart.create!
      cart.cart_items.create!(product_id: 1, quantity: 2)
      expect(cart.total_price).to eq(BigDecimal('2200'))
    end

    it 'cart_itemが2件の時、計算結果が正しいこと' do
      cart = Cart.create!
      cart.cart_items.create!(product_id: 1, quantity: 2)
      cart.cart_items.create!(product_id: 2, quantity: 1)
      expect(cart.total_price).to eq(BigDecimal('3300'))
    end
  end
end
