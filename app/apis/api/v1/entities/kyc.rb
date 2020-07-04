module API
  module V1
    module Entities
      class Kyc < Grape::Entity
        include API::Helpers
        expose :status do |m, o|
          m.kyc.status rescue 'none'
        end
        expose :name do |m, o|
          m.kyc.name rescue nil
        end
        expose :id_no do |m, o| 
          m.kyc.id_no rescue nil
        end
        expose :front_img_url do |m, o| 
          m.kyc.front_img_url rescue nil
        end
        expose :back_img_url do |m, o| 
          m.kyc.back_img_url rescue nil
        end
 
      end
    end
  end
end
