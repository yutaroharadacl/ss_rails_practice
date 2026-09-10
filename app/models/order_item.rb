# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_id, presence: true, uniqueness: { scope: :order_id }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  # 単価は商品のSKU価格を採用する。フォームから受け取った値で上書きされないよう、
  # priceが未設定のときだけ補う（カートからの注文確定は自分でpriceを渡すのでそちらが優先される）。
  before_validation :apply_sku_price, on: :create

  def subtotal
    price * quantity
  end

  private

  def apply_sku_price
    self.price ||= product&.sku&.price
  end
end
