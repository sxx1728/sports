class CreateCoupons < ActiveRecord::Migration[6.0]
  def change
    create_table :coupons do |t|

      t.string :code
      t.references :contract
      t.references :user
      t.decimal :coupon_rate
      t.boolean :is_used
      t.timestamps
    end
  end
end
