class AddTxIdToContractsUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts_users, :tx_id, :string
  end

  def down
    remove_column :contracts_users, :tx_id
  end


end
