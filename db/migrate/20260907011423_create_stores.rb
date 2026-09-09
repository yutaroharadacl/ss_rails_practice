class CreateStores < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:stores)

    create_table :stores do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.index :code, unique: true

      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:stores)

    drop_table :stores
  end
end
