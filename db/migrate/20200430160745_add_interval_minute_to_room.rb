class AddIntervalMinuteToRoom < ActiveRecord::Migration[6.0]
  def up
    add_column :rooms, :interval_minute, :integer
  end

  def down
    remove_column :rooms, :interval_minute
  end


end
