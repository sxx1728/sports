module API
    module V1
      class  Replies < Grape::API
        resource :replies do

          desc '答辩相关'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
