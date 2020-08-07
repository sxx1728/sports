module API
    module V1
      class  ArbitramentResults < Grape::API
        resource :arbitrament_results do

          desc '查看仲裁结果'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
 
          end
          get 'index'do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?

            app_error('无权限查看') unless (contract.arbitrators.include?(user) || contract.renter == user || contract.owner == user)

            present :state, contract.state
            present :result, contract.arbitrament_result, with: API::V1::Entities::ArbitramentResult
            present :arbitraments, contract.arbitraments, with: API::V1::Entities::Arbitrament
          end

        end
      end
    end
  end
