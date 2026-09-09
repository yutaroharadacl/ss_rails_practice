# frozen_string_literal: true

# 商品機能の動作確認用ダミーデータ
# 実行: bin/rails db:seed
# 何度実行しても同じ結果になるよう find_or_create を使う

store = Store.find_or_create_by!(code: 'DEMO') do |s|
  s.name = 'デモ店舗'
end

25.times do |i|
  n = i + 1
  product = store.products.find_or_create_by!(name: "サンプル商品#{n}") do |p|
    p.description = "ページネーション・検索確認用 #{n}"
    p.published = true
  end

  next if product.sku.present?

  product.create_sku!(
    code: format('DEMO-%04d', n),
    price: 1000 + (n * 100),
    stock_quantity: n.even? ? 10 : 0
  )
end

# 管理画面の「非公開」フィルタ確認用
unpublished = store.products.find_or_create_by!(name: '非公開サンプル') do |p|
  p.description = '公開フラグ確認用'
  p.published = false
end
unless unpublished.sku.present?
  unpublished.create_sku!(
    code: 'DEMO-UNPUB',
    price: 999,
    stock_quantity: 1
  )
end

# 店舗名検索の確認用（もう1店舗）
other = Store.find_or_create_by!(code: 'OTHER') do |s|
  s.name = '別店舗サンプル'
end
other_product = other.products.find_or_create_by!(name: '別店舗の商品') do |p|
  p.description = '店舗名検索確認用'
  p.published = true
end
unless other_product.sku.present?
  other_product.create_sku!(
    code: 'OTHER-0001',
    price: 2500,
    stock_quantity: 5
  )
end

puts "Seed completed: stores=#{Store.count}, products=#{Product.count}, skus=#{Sku.count}"
puts "Admin products: /admin/stores/#{store.id}/products"
