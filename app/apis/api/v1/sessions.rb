module API
    module V1
      class  Sessions < Grape::API
        resource :sessions do

          desc '用户登录'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
