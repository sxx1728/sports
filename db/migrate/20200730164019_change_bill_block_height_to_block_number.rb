class ChangeBillBlockHeightToBlockNumber < ActiveRecord::Migration[6.0]
  def up
    change_column :bills, :block_height, :string
  end

  def down
  end


end
