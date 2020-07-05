module API
  module V1
    module Entities
      class Arbitrators < Grape::Entity
        include API::Helpers
        expose :id 
        expose :nick_name 
      end
    end
  end
end
