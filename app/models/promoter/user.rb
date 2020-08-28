module Promoter
  class User < User
    has_many :contracts, foreign_key: "promoter_id"
    has_one :promoter_code, foreign_key: "user_id"

    def has_permission? contract
      contract.promoter == self
    end


  end
end
