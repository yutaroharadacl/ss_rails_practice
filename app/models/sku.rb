# frozen_string_literal: true

class Sku < ApplicationRecord
  belongs_to :product

  # Rails 6.1でuniquenessのデフォルト比較が変わるため、DEPRECATION WARNING回避のため明示している
  validates :code, presence: true, uniqueness: { case_sensitive: true }
  validates :price,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock_quantity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: true

  def in_stock?
    stock_quantity.positive?
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[code price]
  end
end
