class User < ApplicationRecord

  TYPES = ["RENTER" ,"OWNER", "PROMOTER", "ARBITRATOR"]
  def self.valid_type? type
    TYPES.index(type).present?
  end


end
