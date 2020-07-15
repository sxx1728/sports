class AddDescToUser < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :desc, :string
  end

  def down
    remove_column :users, :desc
  end


end
