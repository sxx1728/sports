class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|

      t.references :contract
      t.datetime :at
      t.string :content
      t.string :tx_id

      t.timestamps
    end
  end
end
