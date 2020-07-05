class CreateContractsUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts_users do |t|
      t.references :contract
      t.references :user
    end
  end
end
