class CreateRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :rooms do |t|

      t.integer :no,              null: false, default: 0
      t.string :price_addr,              null: false, default: "", limit: 512
      t.string :join_coin_addr,              null: false, default: "", limit: 512
      t.integer :time_level,              null: false, default: 0
      t.bigint :invent_level,              null: false, default: 0
      t.integer :player_number,              null: false, default: 0
      t.integer :winer_number,              null: false, default: 0
      t.boolean :is_deleted,              null: false, default: false
      t.integer :rate,              null: false, default: 0
      t.integer :cur_round,              null: false, default: 0
      t.datetime :begin_at,              null: false, default: -> {'CURRENT_TIMESTAMP'}
      t.timestamps
    end
  end
end
