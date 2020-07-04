module API
    module V1
      class  TransactionArbitrators < Grape::API
        resource :transaction_arbitrators do

          desc '创建一个交易支付方式'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_id, type: String, desc: "交易id"
            requires :arbitrator_ids, type: Array[String], desc: "交易仲裁人"
          end
          post do
            present 1
          end

        end
      end
    end
  end
