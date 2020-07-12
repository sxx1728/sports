module API
  module V1
    module Entities
      class Bills < Grape::Entity
        include API::Helpers

        expose :id
        expose :pay_at
        expose :item
        expose :amount
        expose :tx_id

      end
    end
  end
end
