class AddGoogleSecretToAdmin < ActiveRecord::Migration[6.0]
  def up
    add_column :admins, :google_secret, :string, limit: 128
  end

  def down
    remove_column :admins, :google_secret
  end

end
