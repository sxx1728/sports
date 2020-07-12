module Promoter
  class User < User
    has_many :contracts, foreign_key: "promoter_id"

    def has_permission? contract
      contract.promoter == self
    end


  end
end
