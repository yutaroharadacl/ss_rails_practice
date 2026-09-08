class ChangeProductIdNullConstraintOnOrderItems < ActiveRecord::Migration[6.0]
  def change
    change_column_null :order_items, :product_id, false
  end
end
