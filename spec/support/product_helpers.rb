# frozen_string_literal: true

module ProductHelpers
  def create_product!(store:, name:, code:, published: true, sku_attributes: {})
    product = store.products.build(name: name, description: '説明', published: published)
    product.build_sku({ code: code, price: 1000, stock_quantity: 10 }.merge(sku_attributes))
    product.save!
    product
  end
end
