module API
  module V1
    module Entities
      class Incomes < Grape::Entity

        expose :id
        expose :at
        expose :item
        expose :amount
        expose :tx_id

      end
    end
  end
end
