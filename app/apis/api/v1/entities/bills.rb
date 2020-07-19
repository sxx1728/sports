module API
  module V1
    module Entities
      class Bills < Grape::Entity
        include API::Helpers

        expose :id
        expose :pay_at
        expose :item
        expose :amount
        expose :paid
        expose :tx_id
        expose :can_pay do |m, o|
          o[:contract].renter == o[:user]
        end

      end
    end
  end
end
