# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def unit_price
    product&.sku&.price.to_i
  end

  validates :product_id, presence: true
  # numericality: 数値化どうかを確かめる
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validate :quantity_must_not_exceed_stock

  private

  def quantity_must_not_exceed_stock
    sku = product&.sku
    return if sku.nil? || quantity.blank?
    return if sku.enough_stock?(quantity)

    errors.add(:quantity, "は在庫数（#{sku.stock_quantity}）以下にしてください")
  end
end
