class AddDescToContractsUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts_users, :desc, :string
  end

  def down
    remove_column :contracts_users, :desc
  end



end
