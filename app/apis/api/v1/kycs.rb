module API
    module V1
      class  Kycs < Grape::API
        resource :kycs do

          desc '更新用户资料'
          params do
            requires :token, type: String, desc: "user token"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            kyc = user.kyc

            present user, with: API::V1::Entities::Kyc
          end

          desc '添加KYC'
          params do
            requires :token, type: String, desc: "user token"
            requires :front_img_id, type: Integer
            requires :back_img_id, type: Integer
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?


            front_img = Image.find(params[:front_img_id]) rescue nil
            app_error('无效front_img_id') unless front_img.present?

            back_img = Image.find(params[:back_img_id]) rescue nil
            app_error('无效back_img_id') unless back_img.present?

            kyc = user.kyc || user.build_kyc

            kyc.front_img = front_img
            kyc.back_img = back_img

            kyc.save!

            present 'succeed'
          end


            
          desc '更新用户资料'
          params do
            requires :token, type: String, desc: "user token"
            requires :front_img_file, type: File
            requires :back_img_file, type: File
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            
 
            present 1
          end


        end
      end
    end
  end
