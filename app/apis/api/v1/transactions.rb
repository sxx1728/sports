module API
    module V1
      class  Transactions < Grape::API
        resource :transactions do

          desc '我的交易列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :state, type: String, desc: "查找交易的状态"
            requires :order_by, type: String, desc: "排序类型"
            requires :is_asc, type: Boolean, desc: "是否升序排列"
            requires :page_num, type: Integer, desc: "页号"
            requires :page_size, type: Integer, desc: "大小"
          end
          get 'index' do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('无效State', 'invalid state') if user.nil?
            transactions = user.transactions.where(status: '')
 
            present 1
          end

          desc '交易详情, 包括各种状态'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_id, type: String, desc: "交易编码"
          end
          get do
            present 1
          end

          desc '创建一个空交易'
          params do
            requires :token, type: String, desc: "user token"

          end
          post do
            present 1
          end

          desc '交易处理'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_id, type: String, desc: "交易编码"
            requires :action, type: String, desc: "交易操作, create/"
          end
          get 'preview' do
            present 1
          end



        end
      end
    end
  end
