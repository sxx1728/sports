class ChangeCouponItemForContract < ActiveRecord::Migration[6.0]
  def up
     rename_column :contracts, :trans_agency_fee_rate_origin,  :trans_platform_fee_rate_origin
  end

  def down
     rename_column :contracts, :trans_platform_fee_rate_origin,  :trans_agency_fee_rate_origin
  end


end
