class RemoveUnusedColumnsFromCartsAndCartItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :cart_items, :unit_price, :integer
    remove_column :carts, :session_id, :string
  end
end
