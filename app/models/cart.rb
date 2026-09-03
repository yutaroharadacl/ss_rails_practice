# frozen_string_literal: true

class Cart < ApplicationRecord
  DUMMY_PRICE = 1000 # 商品モデルが無いための仮価格
  TAX_RATE = 1.1

  # CartとCartItemは1対多の関係、Cartが削除されればそれに紐づくCartItemも削除されるべき
  has_many :cart_items, dependent: :destroy

  def total_price
    # 1.1をかけると結果もfloatになるので金額計算にはそぐわない。なのでBigDecimalを利用する
    total_price = cart_items.sum { |item| item.quantity * DUMMY_PRICE * BigDecimal(TAX_RATE) }
  end
end
