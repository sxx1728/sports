module Promoter
  class User < User
    has_many :contracts, foreign_key: "promoter_id"
  end
end
