module API
    module V1
      class  Users < Grape::API
        resource :users do

          desc '查看用户'
          params do
            requires :token, type: String, desc: "user token"
            requires :type, type: String, desc: "phone type: 'renter' ,'owner', 'promoter', 'arbitrator'"
          end
          get 'index' do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('无效类型', 'invalid type') unless User.valid_type? params[:type]
            users

          end

          desc '查看仲裁列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :arbitrament_code, type: String, desc: "arbitrament_code"
            requires :status, type: String, desc: "仲裁状态查找"
            requires :order_by, type: String, desc: "排序字段"
            requires :is_asc, type: Boolean, desc: "是否增序"
            requires :page_num, type: Integer, desc: "页号"
            requires :page_size, type: Integer, desc: "每页大小"
          end
          get do
            present 1
          end


        end
      end
    end
  end
