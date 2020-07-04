module API
    module V1
      class  TransactionDetails < Grape::API
        resource :transaction_details do

          desc '创建一个交易支付方式'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_id, type: String, desc: "交易id"
            requires :renter_id, type: String, desc: "租客id"
            requires :owner_id, type: String, desc: "房东id"
            requires :currency, type: String, desc: "租金币种"
            requires :monthly_price, type: String, desc: "月租金"
            requires :pledge_amount, type: String, desc: "押金"
            requires :payment_type, type: String, desc: "付款方式"
            requires :coupon_code, type: String, desc: "优惠码"
            requires :fee_rate, type: Float, desc: "交易费率"
            requires :fee_pay_type, type: String, desc: "谁承担费率"
            requires :peroid, type: String, desc: "租期"
            requires :begin_at, type: DateTime, desc: "租期开始"
            requires :end_at, type: DateTime, desc: "租期结束"
          end
          post do
            present 1
          end

        end
      end
    end
  end
