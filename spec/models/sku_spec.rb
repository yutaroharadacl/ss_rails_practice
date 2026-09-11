# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sku, type: :model do
  let!(:store) { Store.create!(name: 'SKU店舗', code: 'SKU-STORE') }
  let!(:product) { create_bare_product!(name: 'SKU商品') }

  # Product には validates :sku, presence: true があるため、Sku側の検証を単体でテストするために
  # あえてSkuを持たない状態のProductをバリデーションをスキップして作成する
  def create_bare_product!(name:)
    product = store.products.new(name: name, published: true)
    product.save!(validate: false)
    product
  end

  def build_sku(attrs = {})
    Sku.new({
      product: product,
      code: 'SKU-001',
      price: 1000,
      stock_quantity: 1
    }.merge(attrs))
  end

  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      expect(build_sku).to be_valid
    end

    it 'codeがない場合は無効' do
      expect(build_sku(code: nil)).not_to be_valid
    end

    it 'codeが重複する場合は無効' do
      product.create_sku!(code: 'SKU-001', price: 1000, stock_quantity: 1)
      other_product = create_bare_product!(name: '別商品')
      sku = Sku.new(product: other_product, code: 'SKU-001', price: 500, stock_quantity: 1)
      expect(sku).not_to be_valid
    end

    it 'priceがない場合は無効' do
      expect(build_sku(price: nil)).not_to be_valid
    end

    it 'priceが負の場合は無効' do
      expect(build_sku(price: -1)).not_to be_valid
    end

    it 'priceが整数でない場合は無効' do
      expect(build_sku(price: 1.5)).not_to be_valid
    end

    it 'stock_quantityがない場合は無効' do
      expect(build_sku(stock_quantity: nil)).not_to be_valid
    end

    it 'stock_quantityが負の場合は無効' do
      expect(build_sku(stock_quantity: -1)).not_to be_valid
    end

    it '1 product に対して複数 SKU は無効' do
      product.create_sku!(code: 'SKU-001', price: 1000, stock_quantity: 1)
      sku = Sku.new(product: product, code: 'SKU-002', price: 500, stock_quantity: 1)
      expect(sku).not_to be_valid
    end
  end

  describe '#in_stock?' do
    it '在庫がある場合は true' do
      sku = product.create_sku!(code: 'SKU-STOCK', price: 1000, stock_quantity: 1)
      expect(sku.in_stock?).to eq(true)
    end

    it '在庫が0の場合は false' do
      sku = product.create_sku!(code: 'SKU-EMPTY', price: 1000, stock_quantity: 0)
      expect(sku.in_stock?).to eq(false)
    end
  end

  describe '#enough_stock?' do
    let(:sku) { product.create_sku!(code: 'SKU-ENOUGH', price: 1000, stock_quantity: 3) }

    it '在庫より少ない数量の場合は true' do
      expect(sku.enough_stock?(2)).to eq(true)
    end

    it '在庫と同じ数量の場合は true' do
      expect(sku.enough_stock?(3)).to eq(true)
    end

    it '在庫を超える数量の場合は false' do
      expect(sku.enough_stock?(4)).to eq(false)
    end

    it '数量がnilの場合は false' do
      expect(sku.enough_stock?(nil)).to eq(false)
    end
  end

  describe '#decrement_stock!' do
    let(:sku) { product.create_sku!(code: 'SKU-DECREMENT', price: 1000, stock_quantity: 3) }

    it '指定した数量だけ在庫が減る' do
      sku.decrement_stock!(2)
      expect(sku.reload.stock_quantity).to eq(1)
    end

    it '在庫と同じ数量の場合は在庫が0になる' do
      sku.decrement_stock!(3)
      expect(sku.reload.stock_quantity).to eq(0)
    end

    it '在庫を超える数量の場合は InsufficientStockError になり、在庫は変わらない' do
      expect { sku.decrement_stock!(4) }.to raise_error(Sku::InsufficientStockError)
      expect(sku.reload.stock_quantity).to eq(3)
    end

    it 'メモリ上の在庫が古い場合でも、読み直した結果で InsufficientStockError になる' do
      # with_lock による読み直しが効いていることの確認（行ロックそのものの検証ではない）。
      # メモリ上のsku(在庫3)を持ったまま、DB側の在庫だけを1に減らす
      Sku.find(sku.id).update!(stock_quantity: 1)

      expect { sku.decrement_stock!(3) }.to raise_error(Sku::InsufficientStockError)
      expect(sku.reload.stock_quantity).to eq(1)
    end
  end
end
