module API
  module V1
    module Entities
      class Appeal < Grape::Entity
        include API::Helpers

        expose :id
        expose :at
        expose :cause
        expose :amount
        expose :images do |m,o|
          m.images.map{ |img|
            Image.find(img).file.url
          }
        end
        expose :chain_data do |m,o|
          "appeal_id:#{m.id}, user_id:#{m.user.id}, cause:#{m.cause}"
        end
        expose :user_type do |m,o|
          m.user.type
        end

      end
    end
  end
end
