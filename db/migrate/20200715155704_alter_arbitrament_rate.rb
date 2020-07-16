class AlterArbitramentRate < ActiveRecord::Migration[6.0]
  def up
    change_column :contracts_users, :renter_rate, :integer
    change_column :contracts_users, :owner_rate, :integer
  end

  def down
  end


end
