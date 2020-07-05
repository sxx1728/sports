class AddNextRoundAtToRoom < ActiveRecord::Migration[6.0]
  def up
    add_column :rooms, :next_round_at, :datetime
  end

  def down
    remove_column :rooms, :next_round_at
  end


end
