class AddPayCycleToBill < ActiveRecord::Migration[6.0]
  def up
    add_column :bills, :pay_cycle, :integer
    add_column :bills, :block_height, :integer
  end

  def down
    remove_column :bills, :pay_cycle
    remove_column :bills, :block_height
  end


end
