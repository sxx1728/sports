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

          desc '修改用户信息'
          params do
            requires :token, type: String, desc: "user token"
            requires :nick_name, type: String, desc: "user nick name"
            requires :eth_wallet_address, type: String, desc: "eth 钱包地址"
          end
          put do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            if params[:nick_name].present?
              app_error('过长nick name') if params[:nick_name].length > 32
              app_error('nick name已被占用') if User.exists?(nick_name: params[:nick_name])
              user.update!(nick_name: params[:nick_name])
            end
            if params[:eth_wallet_address].present?
              app_error('无效eth_wallet_address name') if params[:eth_wallet_address].length != 42
              app_error('无法修改ETH钱包地址') if user.eth_wallet_address.present?
              user.update!(eth_wallet_address: params[:eth_wallet_address])
            end

            present 'succeed'
          end


        end
      end
    end
  end
