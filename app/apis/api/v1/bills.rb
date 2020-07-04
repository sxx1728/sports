module API
    module V1
      class  Bills < Grape::API
        resource :bills do

          desc '收益相关'
          params do
            requires :token, type: String, desc: "user token"
          end
          get 'index' do
            present 1
          end

        end
      end
    end
  end
