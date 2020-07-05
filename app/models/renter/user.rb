module Renter
  class User < User
    has_many :contracts, foreign_key: "renter_id"
  end
end
