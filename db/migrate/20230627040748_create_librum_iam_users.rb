# frozen_string_literal: true

class CreateLibrumIamUsers < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :librum_iam_users, id: :uuid do |t|
      t.string :username, null: false, default: ''
      t.string :email,    null: false, default: ''
      t.string :slug,     null: false, default: ''
      t.string :role,     null: false, default: ''

      t.timestamps
    end

    add_index :librum_iam_users, :email,    unique: true
    add_index :librum_iam_users, :slug,     unique: true
    add_index :librum_iam_users, :username, unique: true
  end
end
