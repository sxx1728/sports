class CreateArbitramentResults < ActiveRecord::Migration[6.0]
  def change
    create_table :arbitrament_results do |t|

      t.references :contract
      t.integer :owner_rate
      t.integer :renter_rate

      t.string :tx_id

      t.timestamps
    end
  end
end
