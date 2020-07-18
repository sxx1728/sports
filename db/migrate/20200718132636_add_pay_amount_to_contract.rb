class AddPayAmountToContract < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :trans_pay_amount, :decimal
    remove_column :contracts, :trans_payment_type
  end

  def down
    remove_column :contracts, :trans_pay_amount
    add_column :contracts, :trans_payment_type, :string
  end
end
