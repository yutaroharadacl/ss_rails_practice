# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_id, presence: true, uniqueness: { scope: :order_id }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  # priceが未設定のときだけSKU価格を補う。フォーム値を捨てているのは
  # order_item_paramsのpermitに:priceが無いからで、ここは上書き防止の処理ではない。
  # カートからの注文確定はpriceを渡してくるので、その値をそのまま使う。
  before_validation :apply_sku_price, on: :create

  def subtotal
    price * quantity
  end

  private

  def apply_sku_price
    self.price ||= product&.sku&.price
  end
end
