module API
  module V1
    module Entities
      class Arbitrament < Grape::Entity
        include API::Helpers
        expose :id 
        expose :desc
        expose :renter_rate
        expose :owner_rate
        expose :chain_data do |m,o|
          "arbitrament_id:#{m.id}, renter:#{m.renter_rate}, owner: #{m.owner_rate}, desc: #{desc}"
        end
      end
    end
  end
end
