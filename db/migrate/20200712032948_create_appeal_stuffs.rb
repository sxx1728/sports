class CreateAppealStuffs < ActiveRecord::Migration[6.0]
  def change
    create_table :appeal_stuffs do |t|

      t.references :appeal
      t.string :file
      t.timestamps
    end
  end
end
