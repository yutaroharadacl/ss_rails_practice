# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      item = CartItem.new(product_id: 1, quantity: 1, cart: Cart.create!)
      expect(item).to be_valid
    end

    it 'product_idがない場合は無効' do
      item = CartItem.new(product_id: nil, quantity: 1, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityがない場合は無効' do
      item = CartItem.new(product_id: 1, quantity: nil, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが0以下の場合は無効' do
      item = CartItem.new(product_id: 1, quantity: 0, cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが数値でない場合は無効' do
      item = CartItem.new(product_id: 1, quantity: 'a', cart: Cart.create!)
      expect(item).not_to be_valid
    end

    it 'quantityが整数でない場合は無効' do
      item = CartItem.new(product_id: 1, quantity: 1.5, cart: Cart.create!)
      expect(item).not_to be_valid
    end
  end
end
