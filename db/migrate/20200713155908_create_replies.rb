class CreateReplies < ActiveRecord::Migration[6.0]
  def change
    create_table :replies do |t|

      t.references :contract
      t.references :user
      
      t.datetime :at
      t.string :reply
      t.string :images
 
      t.timestamps
    end
  end
end
