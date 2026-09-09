class AddColumnsToOrdersAndOrderItems < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :order_number, :string, null: false
    add_index :orders, :order_number, unique: true
    add_column :orders, :status, :string, default: 'new', null: false
    add_reference :orders, :user, null: true, foreign_key: false

    add_column :order_items, :price, :integer, null: false
  end
end
