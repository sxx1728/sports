module API
    module V1
      class  Arbitraments < Grape::API
        resource :arbitraments do

          desc '查看仲裁意见'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
            requires :owner_rate, type: Integer, desc: "房东应得百分比"
            requires :renter_rate, type: Integer, desc: "租客应得百分比"
            requires :desc, type: String, desc: "仲裁说明"
            requires :images, type: Array[Integer], coerce_with: ->(val) { val.split(/\D+/).map(&:to_i)}, desc: "仲裁图片"
 
          end
          post do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('非仲裁用户') unless user.type == 'Arbitrator::User'

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限仲裁') unless contract.arbitrators.include?(user)

            app_error('比例异常，两者相加=100') unless (params[:renter_rate] + params[:owner_rate] == 100)

            images = params[:images].map{|img_id|
              img = Image.find(img_id) rescue nil
              app_error('图像ID无效') if img.nil? || img.user != user
              img_id
            }

            
            contracts_user = ContractsUser.where(user: user, contract: contract).first
            
            app_error('不能重复评判') if contracts_user.done

            server_error('关联无效了') unless contracts_user.present?

            contracts_user.update!(owner_rate: params[:owner_rate], 
                                   renter_rate: params[:renter_rate], 
                                   desc: params[:desc], 
                                   images: params[:images],
                                   done: true)

            present contracts_user.id

          end



          desc '创建仲裁意见'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: Integer, desc: "合同ID"
            requires :owner_rate, type: Integer, desc: "房东应得百分比"
            requires :renter_rate, type: Integer, desc: "租客应得百分比"
            requires :desc, type: String, desc: "仲裁说明"
            requires :images, type: Array[Integer], coerce_with: ->(val) { val.split(/\D+/).map(&:to_i)}, desc: "仲裁图片"
 
          end
          post do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('非仲裁用户') unless user.type == 'Arbitrator::User'

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限仲裁') unless contract.arbitrators.include?(user)

            app_error('比例异常，两者相加=100') unless (params[:renter_rate] + params[:owner_rate] == 100)

            images = params[:images].map{|img_id|
              img = Image.find(img_id) rescue nil
              app_error('图像ID无效') if img.nil? || img.user != user
              img_id
            }

            
            contracts_user = ContractsUser.where(user: user, contract: contract).first
            
            app_error('不能重复评判') if contracts_user.done

            server_error('关联无效了') unless contracts_user.present?

            contracts_user.update!(owner_rate: params[:owner_rate], 
                                   renter_rate: params[:renter_rate], 
                                   desc: params[:desc], 
                                   images: params[:images],
                                   done: true)

            present contracts_user, API::V1::Entities::Arbitrament

          end

        end
      end
    end
  end
