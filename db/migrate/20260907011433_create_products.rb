class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.references :store, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :published, null: false, default: false

      t.index [:store_id, :published]
      t.timestamps
    end
  end
end
