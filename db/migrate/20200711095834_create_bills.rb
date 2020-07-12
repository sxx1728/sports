class CreateBills < ActiveRecord::Migration[6.0]
  def change
    create_table :bills do |t|
      
      t.references :contract
      t.datetime :pay_at
      t.string :item
      t.decimal :amount
      t.string :tx_id

      t.timestamps
    end
  end
end
