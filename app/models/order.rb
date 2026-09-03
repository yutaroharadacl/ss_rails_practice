class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  TAX_RATE = 0.1

  # statusはnewかcompleteのみ。%wは文字列の配列を作成
  validates :status, inclusion: { in: %w[new complete] }
  # accepts_nested_attributes_forに指定するとorderの変更にorder_itemsも含めてあげると自動的に更新してくれる
  accepts_nested_attributes_for :order_items, allow_destroy: true

  def subtotal
    # {&:subtotal}は{ |item| item.subtotal }の省略された書き方
    order_items.sum(&:subtotal)
  end

  def tax
    (subtotal * TAX_RATE).floor
  end

  def total
    subtotal + tax
  end
end
