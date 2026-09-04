# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe '#subtotal' do
    it '単価*数量を返すこと' do
      item = OrderItem.new(price: 300, quantity: 2)
      expect(item.subtotal).to eq(600)
    end
  end
end
