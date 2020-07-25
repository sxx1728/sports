class AddUserIdToAppeal < ActiveRecord::Migration[6.0]
  def up
    add_column :appeals, :user_id, :integer
  end

  def down
    remove_column :appeals, :user_id
  end


end

