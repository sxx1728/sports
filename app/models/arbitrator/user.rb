# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  phone              :string(16)
#  type               :string(16)
#  status             :string(16)
#  nick_name          :string(32)
#  password_md5       :string(32)
#  eth_wallet_address :string(64)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
module Arbitrator
  class User < User

  end
end
