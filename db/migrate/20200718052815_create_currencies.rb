class CreateCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies do |t|

      t.string :name,              null: false, default: "", limit: 32
      t.string :addr,              null: false, default: "", limit: 512
      t.integer :decimals,           null: false, default: 18
 
      t.timestamps
    end
  end
end
