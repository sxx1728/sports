module API
    module V1
      class  Home < Grape::API
        resource :home do

          desc '主页信息'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
