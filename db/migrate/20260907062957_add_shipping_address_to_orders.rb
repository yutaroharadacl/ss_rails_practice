class AddShippingAddressToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_prefecture, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_address_line, :string
  end
end
