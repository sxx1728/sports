class CreateKycs < ActiveRecord::Migration[6.0]
  def change
    create_table :kycs do |t|

      t.references :user
      t.string :name, limit: 32
      t.string :id_no, limit: 32
      t.string :front_img
      t.string :back_img
      t.string :state
 
      t.timestamps
    end
  end
end
