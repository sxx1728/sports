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
      end
    end
  end
end
