class AddBlockHeithToIncome < ActiveRecord::Migration[6.0]
  def up
    add_column :incomes, :block_height, :string
    add_column :incomes, :cycle, :integer
  end

  def down
    remove_column :income, :block_height
    remove_column :income, :cycle
  end


end
