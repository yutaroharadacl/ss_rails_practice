class CreateSkus < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:skus)

    create_table :skus do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false
      t.integer :price, null: false
      t.integer :stock_quantity, null: false, default: 0

      t.index :code, unique: true
      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:skus)

    drop_table :skus
  end
end
