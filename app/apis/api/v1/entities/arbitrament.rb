module API
  module V1
    module Entities
      class Arbitrament < Grape::Entity
        include API::Helpers
        expose :id 
        expose :desc
        expose :renter_rate
        expose :owner_rate
        expose :images do |m,o|
          m.images.map{ |img|
            Image.find(img).file.url
          }
        end
        expose :chain_data do |m,o|
          "arbitrament_id:#{m.id}, renter:#{m.renter_rate}, owner: #{m.owner_rate}, desc: #{m.desc}"
        end
      end
    end
  end
end
