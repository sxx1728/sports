module API
  module V1
    module Entities
      class Contracts < Grape::Entity
        include API::Helpers

        expose :trans_no
        expose :room_area  
        expose :state_desc
        expose :state_color
        expose :trans_no
        expose :summary_desc
      end
    end
  end
end
