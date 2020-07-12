class AddImagesToAppeal < ActiveRecord::Migration[6.0]
  def up
    add_column :appeals, :images, :string
  end

  def down
    remove_column :appeals, :images

  end


end
