class FixColumnTypeForAppeal < ActiveRecord::Migration[6.0]
  def up
    change_column :appeals, :amount, :decimal, precision: 20, scale: 8
  end

  def down
  end


end
