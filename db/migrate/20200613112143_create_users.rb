class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|

      t.string :phone, limit: 16
      t.string :type, limit: 16
      t.string :status, limit: 16
      t.string :nick_name, limit: 32
      t.string :password_md5, limit: 32
      t.string :eth_wallet_address, limit: 64

      t.timestamps
    end
  end
end
