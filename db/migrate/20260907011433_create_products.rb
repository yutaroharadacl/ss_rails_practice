class CreateProducts < ActiveRecord::Migration[6.0]
  def up
    return if data_source_exists?(:products)

    create_table :products do |t|
      t.references :store, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :published, null: false, default: false

      t.index [:store_id, :published]
      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:products)

    drop_table :products
  end
end
