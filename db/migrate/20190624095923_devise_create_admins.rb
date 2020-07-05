# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: "", limit: 128
      t.string :encrypted_password, null: false, default: "", limit: 128

      ## Recoverable
      t.string   :reset_password_token, limit: 128
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip, limit: 32
      t.string   :last_sign_in_ip, limit: 32

      ## Confirmable
      t.string   :confirmation_token, limit: 128
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email, limit: 128 # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token, limit: 128 # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## approved by super admin
      t.boolean :approved, default: false, null: false

      t.timestamps null: false
    end

    add_index :admins, :email,                unique: true
    add_index :admins, :reset_password_token, unique: true
    add_index :admins, :confirmation_token,   unique: true
    add_index :admins, :unlock_token,         unique: true
  end
end
