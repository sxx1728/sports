class FixIsOnChainForContract < ActiveRecord::Migration[6.0]
  def up
     rename_column :contracts, :is_on_chain,  :initialized
  end

  def down
    remove_column :contracts, :initialized
  end


end
