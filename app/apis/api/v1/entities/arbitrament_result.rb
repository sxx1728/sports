module API
  module V1
    module Entities
      class ArbitramentResult < Grape::Entity
        expose :id 
        expose :renter_rate
        expose :owner_rate
        expose :tx_id
      end
    end
  end
end
