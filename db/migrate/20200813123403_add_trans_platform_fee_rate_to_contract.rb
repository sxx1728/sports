class AddTransPlatformFeeRateToContract < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :trans_platform_fee_rate, :decimal, precision: 20, scale: 8
  end

  def down
    remove_column :contracts, :trans_platform_fee_rate
  end


end
