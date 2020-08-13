class CreateConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :configs do |t|

      t.string :item
      t.string :value
      t.timestamps
    end
  end
end
