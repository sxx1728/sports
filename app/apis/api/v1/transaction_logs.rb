module API
    module V1
      class  Transaction_logs < Grape::API
        resource :transaction_logs do

          desc '交易日志'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
