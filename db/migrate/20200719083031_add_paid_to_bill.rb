class AddPaidToBill < ActiveRecord::Migration[6.0]
  def up
    add_column :bills, :paid, :boolean
  end

  def down
    remove_column :bills, :paid
  end

end
