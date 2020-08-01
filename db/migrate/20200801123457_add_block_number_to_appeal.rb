class AddBlockNumberToAppeal < ActiveRecord::Migration[6.0]
  def up
    add_column :appeals, :block_number, :string
    add_column :replies, :block_number, :string
  end

  def down
    remove_column :appeals, :block_number
    remove_column :replies, :block_number
  end

end
