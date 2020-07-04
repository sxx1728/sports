module API
    module V1
      class  Registrators < Grape::API
        resource :registrators do

          desc '新用户注册'
          params do
            requires :phone, type: String, desc: "phone number"
            requires :captcha, type: String, desc: "captcha"
            requires :type, type: String, desc: "phone type: 'rent' ,'owner', 'promote', 'arbitrator'"
            requires :password_md5, type: String, desc: "password_md5, salt: rent-{password}-{phone}"
          end
          post do
            app_error('无效类型', 'invalid type') unless User.valid_type? params[:type]
            app_error('无效电话', 'invalid phone') unless Captcha.valid_phone? params[:phone]
            app_error('无效验证码', 'invalid captcha') unless Captcha.valid_captcha? params[:captcha]
            app_error('验证码错误', 'captcha incorrect') unless Captcha.where(phone: params[:phone], captcha: params[:captcha])
              .where("expire_at > ?", DateTime.current).exists?
            app_error('无效密码', 'password_md5 incorrect') unless params[:password_md5].present?
            Captcha.where(phone: params[:phone], captcha: params[:captcha]).where("expire_at > ?", DateTime.current)
              .update_all(expire_at: DateTime.current)

            app_error('手机号已占用', 'phone ocupied') if User.exists?(phone: params[:phone])
            "#{params[:type].capitalize}::User".constantize.create(phone: params[:phone],
                        password_md5: params[:password_md5], 
                        nick_name: User.generate_nick_name)

            present 'succeed'
          end

        end
      end
    end
  end
