class AddDesiredDeliveryDateToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :desired_delivery_date, :date
  end
end
