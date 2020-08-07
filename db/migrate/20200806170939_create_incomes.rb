class CreateIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :incomes do |t|

      t.references :contract
      t.datetime :at
      t.string :item
      t.decimal :amount, precision: 20, scale: 8
      t.string :currency
      t.string :tx_id

 
      t.timestamps
    end
  end
end
