class CreateCaptchas < ActiveRecord::Migration[6.0]
  def change
    create_table :captchas do |t|
      t.string :phone, limit: 16
      t.string :captcha, limit: 8
      t.datetime :expire_at
      t.timestamps
    end
  end
end
