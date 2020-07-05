class User < ApplicationRecord

  has_one :kyc

  TYPES = ['renter' ,'owner', 'promoter', 'arbitrator']

  def self.valid_type? type
    return false if type.blank?
    TYPES.index(type.downcase).present?
  end

  def token
    payload = {
      id: self.id
    }
    token = JWT.encode payload, ENV['RENT_JWT_SECRET'], 'HS256'
    
  end

  def self.from_token token
    payload = JWT.decode token, ENV['RENT_JWT_SECRET'], true, { algorithm: 'HS256' }

    return nil if payload.empty?
    user_id = payload[0]["id"]
    return nil if user_id.blank?

    User.find(user_id)
  end

  def self.generate_nick_name
    "用户#{SecureRandom.rand(1000000..9999999)}"
  end


end
