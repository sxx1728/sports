module API
  module V1
    module Entities
      class Arbitrators < Grape::Entity
        include API::Helpers
        expose :id 
        expose :nick_name 
        expose :desc
      end
    end
  end
end
