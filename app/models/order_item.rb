# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order

  validates :product_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    price * quantity
  end
end
