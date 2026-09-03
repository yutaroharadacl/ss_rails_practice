# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart

  validates :product_id, presence: true
  # numericality: 数値化どうかを確かめる
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
