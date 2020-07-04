module API
  module V1
    module Entities
      class Contracts < Grape::Entity
        include API::Helpers
        expose :title do |m, o|
          "#{m.room_area}"
        end
        expose :state_desc
        expose :state_color
        expose :trans_no
        expose :summary_desc
      end
    end
  end
end
