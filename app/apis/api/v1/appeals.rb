module API
    module V1
      class  Appeals < Grape::API
        resource :appeals do

          desc '创建申诉相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: String, desc: "transaction code"
            requires :images, type: Array[Integer], coerce_with: ->(val) { 
              val.split(/\D+/).map(&:to_i) 
            },  desc: "申诉图片"
            requires :cause, type: String, desc: "申诉理由"
            requires :amount, type: Float, desc: "申诉金额"
 
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?
            app_error('无效合同状态') unless contract.running?

            app_error('申诉理由不能为空') unless params[:cause].present?
            app_error('申诉金额不能为空') unless params[:amount].present?

            images = params[:images].map{|img_id|
              img = Image.find(img_id) rescue nil
              app_error('图像ID无效') if img.nil? || img.user != user
              img_id
            }
 
            begin
              contract.launch_appeal!(user, params[:appeal_tx_id])
            rescue AASM::InvalidTransition => e
              app_error(e.message)
            end
            contract.build_appeal(cause: params[:cause], amount: params[:amount], images: images, at: DateTime.current).save!

            present contract.appeal, with: API::V1::Entities::Appeal
          end


          desc '查看申诉详情'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: String, desc: "transaction code"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?

            app_error('用户无权限') unless  contract.renter == user or contract.owner == user or contract.arbitrators.include?(user)

            present contract.appeal, with: API::V1::Entities::Appeal
          end


        end
      end
    end
  end
