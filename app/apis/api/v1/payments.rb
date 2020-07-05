module API
    module V1
      class  Payments < Grape::API
        resource :payments do

          desc '收益相关'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
