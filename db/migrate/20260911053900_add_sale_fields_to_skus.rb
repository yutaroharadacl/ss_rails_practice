# frozen_string_literal: true

class AddSaleFieldsToSkus < ActiveRecord::Migration[6.0]
  def up
    return unless data_source_exists?(:skus)

    add_column :skus, :sale_price, :integer unless column_exists?(:skus, :sale_price)
    add_column :skus, :sale_starts_at, :datetime unless column_exists?(:skus, :sale_starts_at)
    add_column :skus, :sale_ends_at, :datetime unless column_exists?(:skus, :sale_ends_at)
  end

  def down
    return unless data_source_exists?(:skus)

    remove_column :skus, :sale_price if column_exists?(:skus, :sale_price)
    remove_column :skus, :sale_starts_at if column_exists?(:skus, :sale_starts_at)
    remove_column :skus, :sale_ends_at if column_exists?(:skus, :sale_ends_at)
  end
end
