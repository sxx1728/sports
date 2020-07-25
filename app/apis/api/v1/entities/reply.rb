module API
  module V1
    module Entities
      class Reply < Grape::Entity
        include API::Helpers

        expose :at
        expose :reply
        expose :images do |m,o|
          m.images.map{ |img|
            Image.find(img).file.url
          }
        end
        expose :chain_data do |m,o|
          "reply_id:#{m.id}, user_id:#{m.user.id}, cause:#{m.reply}"
        end
        expose :user_type do |m,o|
          m.user.type
        end
      end
    end
  end
end
