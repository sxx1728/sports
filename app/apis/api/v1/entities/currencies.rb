module API
  module V1
    module Entities
      class Currencies < Grape::Entity
        expose :name
      end
    end
  end
end
