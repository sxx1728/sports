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
            app_error('无效Token', 'invalid token') if user.nil?

            kyc = user.kyc

            present user, with: API::V1::Entities::Kyc
          end

          desc '添加KYC'
          params do
            requires :token, type: String, desc: "user token"
            requires :front_img_file, type: File
            requires :back_img_file, type: File
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 'invalid token') if user.nil?

            kyc = user.kyc || user.build_kyc
            binding.pry

            kyc.front_img = params[:front_img_file][:tempfile]
            kyc.back_img = params[:back_img_file][:tempfile]

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
            app_error('无效Token', 'invalid token') if user.nil?

            
 
            present 1
          end


        end
      end
    end
  end
