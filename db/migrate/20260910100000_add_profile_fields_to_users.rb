# frozen_string_literal: true

class AddProfileFieldsToUsers < ActiveRecord::Migration[6.0]
  def up
    return unless data_source_exists?(:users)

    add_column :users, :name, :string unless column_exists?(:users, :name)
    add_column :users, :name_kana, :string unless column_exists?(:users, :name_kana)
    add_column :users, :address, :string unless column_exists?(:users, :address)
    add_column :users, :phone, :string unless column_exists?(:users, :phone)
    add_column :users, :fax, :string unless column_exists?(:users, :fax)
  end

  def down
    return unless data_source_exists?(:users)

    remove_column :users, :name if column_exists?(:users, :name)
    remove_column :users, :name_kana if column_exists?(:users, :name_kana)
    remove_column :users, :address if column_exists?(:users, :address)
    remove_column :users, :phone if column_exists?(:users, :phone)
    remove_column :users, :fax if column_exists?(:users, :fax)
  end
end
