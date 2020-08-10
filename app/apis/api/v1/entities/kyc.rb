module API
  module V1
    module Entities
      class Kyc < Grape::Entity
        include API::Helpers
        expose :status do |m, o|
          m.state rescue 'none'
        end
        expose :name do |m, o|
          m.name rescue nil
        end
        expose :id_no do |m, o| 
          m.id_no rescue nil
        end
        expose :front_img_url do |m, o| 
          m.front_img.file_url rescue nil
        end
        expose :back_img_url do |m, o| 
          m.back_img.file_url rescue nil
        end
 
      end
    end
  end
end
