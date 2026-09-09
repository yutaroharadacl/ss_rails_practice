# frozen_string_literal: true

module ProductHelpers
  def create_product!(store:, name:, code:, published: true, price: 1000, stock_quantity: 10)
    product = store.products.build(name: name, description: '説明', published: published)
    product.build_sku(code: code, price: price, stock_quantity: stock_quantity)
    product.save!
    product
  end
end
