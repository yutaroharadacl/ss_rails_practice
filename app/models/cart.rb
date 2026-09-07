# frozen_string_literal: true

class Cart < ApplicationRecord
  DUMMY_PRICE = 1000 # 商品モデルが無いための仮価格

  # CartとCartItemは1対多の関係、Cartが削除されればそれに紐づくCartItemも削除されるべき
  has_many :cart_items, dependent: :destroy

  def total_price
    # Floatを経由すると誤差が出るため、税率(TaxRate::PERCENT)をBigDecimalに変換してから掛ける
    tax_multiplier = 1 + (BigDecimal(TaxRate::PERCENT) / 100)
    cart_items.sum { |item| item.quantity * DUMMY_PRICE * tax_multiplier }
  end
end
