# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order

  validates :product_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end