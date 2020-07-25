class FixColumnNameOwnerNameForContract < ActiveRecord::Migration[6.0]
  def up
     rename_column :contracts, :room_owner_name,  :room_certificate_owner
  end

  def down
    remove_column :contracts, :room_certificate_owner,  :room_owner_name
  end


end
