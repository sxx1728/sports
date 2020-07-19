module API
    module V1
      class  Bills < Grape::API
        resource :bills do

          desc '收益相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
          end
          get 'index' do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限') unless user.has_permission?(contract)
    
            bills = contract.bills

            present bills, with: API::V1::Entities::Bills, contract: contract, user: user
          end

        end
      end
    end
  end
