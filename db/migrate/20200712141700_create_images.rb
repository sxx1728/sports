class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|

      t.references :user
      t.string :file
      t.timestamps
    end
  end
end
