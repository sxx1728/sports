module API
    module V1
      class  Arbitrators < Grape::API
        resource :arbitrators do

          desc '随机查看5个仲裁人员'
          params do
            requires :token, type: String, desc: "user token"
          end
          get 'index' do

            user = User.from_token params[:token]
            app_error('无效Token', 'invalid token') if user.nil?

            rand_ids = Arbitrator::User.ids.sort_by{rand}.slice(0,5)
            users = Arbitrator::User.where(id: rand_ids)

            present users, with: API::V1::Entities::Arbitrators

          end

        end
      end
    end
  end
