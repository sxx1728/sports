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
            optional :nick_name, type: String, desc: "user nick name"
            optional :desc, type: String, desc: "介绍"
            optional :eth_wallet_address, type: String, desc: "eth 钱包地址"
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
              app_error('无效eth_wallet_address长度') unless params[:eth_wallet_address].length == 42
              app_error('无效eth_wallet_address，前缀0x') unless params[:eth_wallet_address][0..1] == '0x'
              app_error('eth_wallet_address重复，请使用其他地址') if User.where(eth_wallet_address: params[:eth_wallet_address]).exists? 
              #app_error('无法修改ETH钱包地址') if user.eth_wallet_address.present?
              user.update!(eth_wallet_address: params[:eth_wallet_address])
            end

            if params[:desc].present?
              app_error('过长nick name') if params[:desc].length > 1024
              user.update!(desc: params[:desc])
            end
            present 'succeed'
          end


        end
      end
    end
  end
