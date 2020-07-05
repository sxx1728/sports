class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|

      t.references :renter, references: :user
      t.references :owner, references: :user
      t.references :promoter, references: :user

      t.string :state

      t.string :room_address
      t.string :room_district
      t.decimal :room_area
      t.string :room_no
      t.string :room_owner_name
      t.string :room_usage
      t.integer :room_capacity_min
      t.integer :room_capacity_max
      t.boolean :room_is_pledged
      t.string :room_certificate

      t.string :trans_no
      t.string :trans_currency
      t.decimal :trans_monthly_price
      t.decimal :trans_pledge_amount
      t.string :trans_amount_pledge
      t.string :trans_payment_type
      t.string :trans_coupon_code
      t.decimal :trans_agency_fee_rate
      t.string :trans_agency_fee_by
      t.integer :trans_period
      t.date :trans_begin_on
      t.date :trans_end_on

      t.timestamps
    end
  end
end
