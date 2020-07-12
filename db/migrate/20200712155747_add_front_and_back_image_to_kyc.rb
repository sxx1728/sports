class AddFrontAndBackImageToKyc < ActiveRecord::Migration[6.0]
  def up
    add_column :kycs, :front_img_id, :integer
    add_column :kycs, :back_img_id, :integer

    remove_column :kycs, :front_img
    remove_column :kycs, :back_img

  end

  def down
    remove_column :kycs, :front_img_id
    remove_column :kycs, :back_img_id

    add_column :kycs, :front_img, :integer
    add_column :kycs, :back_img, :integer

  end


end
