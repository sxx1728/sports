class CreateAppeals < ActiveRecord::Migration[6.0]
  def change
    create_table :appeals do |t|

      t.references :contract
      t.references :user
      t.datetime :at
      t.string :cause
      t.string :amount
      t.string :tx_id
      t.timestamps
    end
  end
end
