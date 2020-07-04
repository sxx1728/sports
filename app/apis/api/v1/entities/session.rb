module API
  module V1
    module Entities
      class Session < Grape::Entity
        include API::Helpers
        expose :type do |m,o|
          m.type.split('::')[1]
        end
        expose :token
      end
    end
  end
end
