class CreateChainlyConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :chainly_configs do |t|

      t.integer :platform_fee_rate
      t.integer :promoter_fee_rate
      t.integer :arbitration_fee_rate

      t.timestamps
    end
  end
end
