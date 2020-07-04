module API
    module V1
      class  Profiles < Grape::API
        resource :profiles do

          desc '查看用户资料'
          params do
            requires :token, type: String, desc: "user token"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 'invalid token') if user.nil?
 
            present user, with: API::V1::Entities::Profile
          end

        end
      end
    end
  end
