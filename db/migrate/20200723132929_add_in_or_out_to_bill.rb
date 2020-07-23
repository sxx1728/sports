class AddInOrOutToBill < ActiveRecord::Migration[6.0]
  def up
    add_column :bills, :in_or_out, :boolean, default: true
    change_column :bills, :amount, :decimal, precision: 20, scale: 8
  end

  def down
    remove_column :bills, :in_or_out
  end


end
