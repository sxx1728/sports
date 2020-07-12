module API
  module V1
    module Entities
      class Profile < Grape::Entity
        include API::Helpers
        expose :type do |m, o|
          m.type.split('::')[0]
        end
        expose :nick_name
        expose :eth_wallet_address
        expose :phone
        expose :kyc, using: API::V1::Entities::Kyc
      end
    end
  end
end
