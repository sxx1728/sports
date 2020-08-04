class AddTxIdToReply < ActiveRecord::Migration[6.0]
  def up
    add_column :replies, :tx_id, :string
  end

  def down
    remove_column :appeals, :tx_id
  end


end
