class CreatePromoterCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :promoter_codes do |t|

      t.references :user
      t.string :code
      t.boolean :enabled
      t.timestamps
    end
  end
end
