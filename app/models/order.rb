# frozen_string_literal: true

class Order < ApplicationRecord
  # statusの値と日本語ラベルの対応（一覧表示・検索フォームの両方から参照する）
  STATUS_LABELS = { 'new' => '新規', 'complete' => '完了' }.freeze

  # 検索可能な属性を許可する
  def self.ransackable_attributes(_auth_object = nil)
    %w[id order_number status]
  end

  # 関連テーブルの検索を許可しない
  def self.ransackable_associations(_auth_object = nil)
    []
  end

  before_create :generate_order_number

  has_many :order_items, dependent: :destroy

  # statusはnewかcompleteのみ。%wは文字列の配列を作成
  validates :status, inclusion: { in: %w[new complete] }
  validates :payment_status, inclusion: { in: %w[pending paid failed] }
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

  # 10桁のランダムな英数字を作成
  # TODO: 衝突した時の再実行処理が必要かどうか
  def generate_order_number
    self.order_number = SecureRandom.alphanumeric(10)
  end
end
