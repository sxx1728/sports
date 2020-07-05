module API
    module V1
      class  Appeals < Grape::API
        resource :appeals do

          desc '申诉相关'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
