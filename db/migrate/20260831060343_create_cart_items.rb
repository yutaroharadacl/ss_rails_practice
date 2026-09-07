class CreateCartItems < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:cart_items)

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.integer :product_id
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price

      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:cart_items)

    drop_table :cart_items
  end
end
