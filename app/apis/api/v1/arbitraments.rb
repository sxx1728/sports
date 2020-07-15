module API
    module V1
      class  Arbitraments < Grape::API
        resource :arbitratraments do

          desc '创建仲裁意见'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
            requires :owner_rate, type: Float, desc: "房东应得"
            requires :renter_rate, type: Float, desc: "租客应得"
            requires :content, type: Float, desc: "租客应得"
          end
          post do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('非仲裁用户') unless user.type == 'Arbitratoer::User'

            contract = Contract.find params[:id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限仲裁') unless contract.arbitrators.include?(user)

            present users, with: API::V1::Entities::Arbitrators

          end

        end
      end
    end
  end
