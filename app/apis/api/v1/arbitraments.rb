module API
    module V1
      class  Arbitraments < Grape::API
        resource :arbitraments do

          desc '仲裁相关'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
