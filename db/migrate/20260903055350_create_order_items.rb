class CreateOrderItems < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:order_items)

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :product_id
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end

    add_index :order_items, [:order_id, :product_id], unique: true
  end

  def down
    return unless data_source_exists?(:order_items)

    drop_table :order_items
  end
end
