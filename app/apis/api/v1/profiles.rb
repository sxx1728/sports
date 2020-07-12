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
            app_error('无效Token', 401) if user.nil?
 
            present user, with: API::V1::Entities::Profile
          end

          desc '修改用户nick name'
          params do
            requires :token, type: String, desc: "user token"
            requires :nick_name, type: String, desc: "user nick name"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('无效nick name', 'invalid nick name') if params[:nick_name].nil?
            app_error('过长nick name', 'nick name too long') if params[:nick_name].length > 32
            app_error('nick name已被占用', 'nick name repeat') if User.exists?(nick_name: params[:nick_name])

            user.update(nick_name: params[:nick_name])

            present 'succeed'
          end


        end
      end
    end
  end
