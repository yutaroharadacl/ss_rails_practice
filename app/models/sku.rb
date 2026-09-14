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
  validates :sale_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: :price },
            allow_nil: true
  validates :stock_quantity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: true
  validate :sale_fields_must_be_complete
  validate :sale_period_must_be_in_order

  def in_stock?
    stock_quantity.positive?
  end

  # 今この瞬間の販売単価。セール適用中だけ sale_price、それ以外は定価。
  def current_price
    on_sale? ? sale_price : price
  end

  # セール価格・開始・終了がすべて入り、かつ今が期間内（両端含む）のときだけ true。
  def on_sale?
    return false unless sale_complete?

    Time.current.between?(sale_starts_at, sale_ends_at)
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

  # decrement_stock!と同様に行ロックを取ってから最新の在庫を読み直して加算する
  def increment_stock!(quantity)
    with_lock do
      update!(stock_quantity: stock_quantity + quantity)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[code price]
  end

  private

  def sale_complete?
    !sale_price.nil? && sale_starts_at.present? && sale_ends_at.present?
  end

  def sale_specified?
    !sale_price.nil? || sale_starts_at.present? || sale_ends_at.present?
  end

  def sale_fields_must_be_complete
    return unless sale_specified?
    return if sale_complete?

    errors.add(:base, 'セール価格とセール期間はセットで入力してください')
  end

  def sale_period_must_be_in_order
    return if sale_starts_at.blank? || sale_ends_at.blank?
    return if sale_starts_at <= sale_ends_at

    errors.add(:sale_ends_at, 'は開始日時以降にしてください')
  end
end
