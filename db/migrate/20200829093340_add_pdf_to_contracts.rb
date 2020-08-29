class AddPdfToContracts < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :pdf, :string
  end

  def down
    remove_column :contracts, :string
  end


end
