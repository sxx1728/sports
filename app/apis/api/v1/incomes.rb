module API
    module V1
      class  Incomes < Grape::API
        resource :incomes do

          desc '某个用户的收益记录'
          params do
            requires :token, type: String, desc: "user token"
          end
          get 'index' do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
    
            incomes = user.incomes

            present incomes, with: API::V1::Entities::Incomes
          end

        end
      end
    end
  end
