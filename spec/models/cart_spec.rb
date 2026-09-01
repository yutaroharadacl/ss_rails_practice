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
end
