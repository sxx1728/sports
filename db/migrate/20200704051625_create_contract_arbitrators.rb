class CreateContractArbitrators < ActiveRecord::Migration[6.0]
  def change
    create_table :contract_arbitrators do |t|
      t.references :contract
      t.references :arbitrator, refrences: :user
      t.timestamps
    end
  end
end
