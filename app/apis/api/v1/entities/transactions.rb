module API
  module V1
    module Entities
      class Transactions < Grape::Entity
        expose :id
        expose :at
        expose :content
        expose :tx_id

      end
    end
  end
end
