class CreateCarts < ActiveRecord::Migration[6.0]
  # upとdownに分けることで下記のコマンドなどで指定することができる
  # bin/rails db:migrate:up VERSION=20260831055953
  # bin/rails db:migrate:down VERSION=20260831055953
  def up
    return if data_source_exists?(:carts)

    create_table :carts do |t|
      t.string :session_id

      t.timestamps
    end
  end

  def down
    return unless data_source_exists?(:carts)

    drop_table :carts
  end
end
