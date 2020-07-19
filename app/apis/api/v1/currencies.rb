module API
    module V1
      class  Currencies < Grape::API
        resource :currencies do

          desc '查看所有支持币种 '
          params do
            requires :token, type: String, desc: "user token"
          end
          get 'index' do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            currencies = Currency.all 

            present currencies, with: API::V1::Entities::Currencies
          end


        end
      end
    end
  end
