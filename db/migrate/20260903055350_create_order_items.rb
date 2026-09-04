class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :product_id
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end

    add_index :order_items, [:order_id, :product_id], unique: true
  end
end
