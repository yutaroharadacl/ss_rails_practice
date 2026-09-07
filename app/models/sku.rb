class Sku < ApplicationRecord
  belongs_to :product

  validates :code, presence: true, uniqueness: true
  validates :price,
            presence: true,
            numericality: {only_integer: true,greater_than_or_equal_to: 0}
  validates :stock_quantity,
            presence: true,
            numericality: {only_integer: true,greater_than_or_equal_to: 0}
  validates :product_id, uniqueness: true

  def in_stock?
    stock_quantity.positive?
  end
end
