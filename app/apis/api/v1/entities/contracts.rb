module API
  module V1
    module Entities
      class Contracts < Grape::Entity
        include API::Helpers

        expose :id
        expose :room_area  
        expose :state_desc do |m,o| 
          m.state_desc o[:user]
        end
        expose :trans_no
        expose :trans_payment_type
        expose :trans_monthly_price
        expose :trans_currency
        expose :trans_begin_on
        expose :trans_end_on
        expose :room_district
      end
    end
  end
end
