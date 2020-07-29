class AddImagesToContractsUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts_users, :images, :string
    add_column :contracts_users, :at, :DateTime
  end

  def down
    remove_column :contracts_users, :images
    remove_column :contracts_users, :at
  end


end
