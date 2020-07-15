class User < ApplicationRecord

  has_one :kyc
  has_many :appeals
  has_many :images

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
    payload = JWT.decode token, ENV['RENT_JWT_SECRET'], true, { algorithm: 'HS256' } rescue nil

    return nil if payload.nil? || payload.empty?
    user_id = payload[0]["id"]
    return nil if user_id.blank?

    User.find(user_id) rescue nil
  end

  def self.generate_nick_name
    "用户#{SecureRandom.rand(1000000..9999999)}"
  end

  def has_permission? contract
    self == contract.renter || self == contract.owner || self == contract.promoter || contract.arbitrators.include?(self)
  end


  
end
