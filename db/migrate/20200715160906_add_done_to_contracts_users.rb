class AddDoneToContractsUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts_users, :done, :boolean, default: false
  end

  def down
    remove_column :contracts_users, :done
  end


end
