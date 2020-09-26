module API
  module V1
    module Entities
      class Profile < Grape::Entity
        include API::Helpers
        expose :id
        expose :type do |m, o|
          m.type.split('::')[0]
        end
        expose :nick_name
        expose :eth_wallet_address
        expose :phone
        expose :desc
        expose :kyc, using: API::V1::Entities::Kyc
        expose :promote_code do |m,o|
          if m.type == 'Promoter::User'
            m.promoter_code.try(:code)
          else
            nil
          end
        end
      end
    end
  end
end
