module API
  module V1
    module Entities
      class Incomes < Grape::Entity

        expose :id
        expose :at
        expose :item do |m, o|
          m.item_desc
        end
        expose :amount
        expose :currency
        expose :tx_id

      end
    end
  end
end
