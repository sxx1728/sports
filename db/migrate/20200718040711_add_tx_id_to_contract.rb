class AddTxIdToContract < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :chain_address, :string
    add_column :contracts, :is_on_chain, :boolean, default: false, allow_null: false
    add_column :contracts, :currency_id, :integer
  end

  def down
    remove_column :contracts, :chain_address
    remove_column :contracts, :is_on_chain
    remove_column :contracts, :currency_id
  end


end
