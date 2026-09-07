# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  # statusはnewかcompleteのみ。%wは文字列の配列を作成
  validates :status, inclusion: { in: %w[new complete] }
  # accepts_nested_attributes_forに指定するとorderの変更にorder_itemsも含めてあげると自動的に更新してくれる
  accepts_nested_attributes_for :order_items, allow_destroy: true

  def editable?
    status == 'new'
  end

  def subtotal
    # {&:subtotal}は{ |item| item.subtotal }の省略された書き方
    # tax/totalからも呼ばれるので、1回のリクエストで何度呼ばれても再計算しないようメモ化する
    @subtotal ||= order_items.sum(&:subtotal)
  end

  def tax
    # price/quantityがどちらもIntegerなので、Floatを経由せず整数の割り算だけで
    # 税額を計算する（Integer#/ は切り捨てなので、以前のfloorと同じ結果になる）
    subtotal * TaxRate::PERCENT / 100
  end

  def total
    subtotal + tax
  end
end
