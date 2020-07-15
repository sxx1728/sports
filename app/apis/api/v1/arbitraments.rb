module API
    module V1
      class  Arbitraments < Grape::API
        resource :arbitraments do

          desc '创建仲裁意见'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
            requires :owner_rate, type: Float, desc: "房东应得"
            requires :renter_rate, type: Float, desc: "租客应得"
            requires :desc, type: Float, desc: "仲裁说明"
            requires :images, type: Array[Integer], coerce_with: ->(val) { val.split(/\D+/).map(&:to_i)}, desc: "仲裁图片"
 
          end
          post do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('非仲裁用户') unless user.type == 'Arbitratoer::User'

            contract = Contract.find params[:id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限仲裁') unless contract.arbitrators.include?(user)

            images = params[:images].map{|img_id|
              img = Image.find(img_id) rescue nil
              app_error('图像ID无效') if img.nil? || img.user != user
              img_id
            }

            
            contracts_user = ContractUser.where(user: user, contract: contract).first
            server_error('关联无效了') unless contracts_user.present?

            contracts_user.update!(owner_rate: params[:owner_rate], 
                                   renter_rate: params[:renter_rate], 
                                   desc: parmas[:desc], 
                                   images: parmas[:images])

 
            present contracts_user.id

          end

        end
      end
    end
  end
