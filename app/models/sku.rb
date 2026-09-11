# frozen_string_literal: true

class Sku < ApplicationRecord
  # 在庫が足りない状態で減算しようとしたときに発生する
  class InsufficientStockError < StandardError; end

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

  def enough_stock?(quantity)
    return false if quantity.blank?

    stock_quantity >= quantity
  end

  # 在庫チェックと減算の間に他の注文が割り込まないよう、行ロック(SELECT ... FOR UPDATE)を
  # 取って最新の在庫を読み直してから減算する
  def decrement_stock!(quantity)
    with_lock do
      raise InsufficientStockError unless enough_stock?(quantity)

      update!(stock_quantity: stock_quantity - quantity)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[code price]
  end
end
