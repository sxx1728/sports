module API
    module V1
      class  Transactions < Grape::API
        resource :transactions do

          desc '交易信息'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
