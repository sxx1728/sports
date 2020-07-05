module API
    module V1
      class  Registrators < Grape::API
        resource :registrators do

          desc '注册用户'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
