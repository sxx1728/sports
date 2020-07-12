module API
    module V1
      class  Appeals < Grape::API
        resource :appeals do

          desc '创建申诉相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: String, desc: "transaction code"
            requires :appeal_tx_id, type: String, desc: "申诉上链交易ID"
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?

            app_error('无效仲裁tx') unless contract.check_appeal_tx_id?(params[:appeal_tx_id])

            begin
              contract.launch_appeal user, params[:appeal_tx_id]
            rescue AASM::InvalidTransition => e
              app_error(e.message)
            end

            present contract.appeal.id
          end

          desc '更新申诉材料相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :appeal_id, type: String, desc: "appeal id"
            requires :images, type: Array[File], desc: "申诉图片"
          end
          put do
            present 1
          end

          desc '查看仲裁列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :arbitrament_code, type: String, desc: "arbitrament_code"
            requires :status, type: String, desc: "仲裁状态查找"
            requires :order_by, type: String, desc: "排序字段"
            requires :is_asc, type: Boolean, desc: "是否增序"
            requires :page_num, type: Integer, desc: "页号"
            requires :page_size, type: Integer, desc: "每页大小"
          end
          get do
            present 1
          end


        end
      end
    end
  end
