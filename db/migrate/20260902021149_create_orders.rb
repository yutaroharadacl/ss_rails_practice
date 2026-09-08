class CreateOrders < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:orders)

    create_table :orders do |t|
      t.string :payment_status, null: false, default: 'pending'

      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:orders)

    drop_table :orders
  end
end
