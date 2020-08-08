class AddUserIdToIncome < ActiveRecord::Migration[6.0]
  def up
    add_column :incomes, :user_id, :integer
  end

  def down
    remove_column :income, :user_id
  end


end
