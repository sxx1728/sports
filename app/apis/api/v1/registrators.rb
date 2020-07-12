module API
    module V1
      class  Registrators < Grape::API
        resource :registrators do

          desc '新用户注册'
          params do
            requires :phone, type: String, desc: "phone number"
            requires :captcha, type: String, desc: "captcha"
            requires :type, type: String, desc: "phone type: 'renter' ,'owner', 'promoter', 'arbitrator'"
            requires :password_md5, type: String, desc: "password_md5, salt: rent-{password}-{phone}"
          end
          post do
            app_error('无效类型') unless User.valid_type? params[:type]
            app_error('无效电话') unless Captcha.valid_phone? params[:phone]
            app_error('无效验证码') unless Captcha.valid_captcha? params[:captcha]
            app_error('验证码错误') unless Captcha.where(phone: params[:phone], captcha: params[:captcha]).exists?
            app_error('无效密码') unless params[:password_md5].present?

            captcha = Captcha.where(phone: params[:phone], captcha: params[:captcha]).last;
            app_error('验证码已过期') unless captcha.expire_at >  DateTime.current

            app_error('手机号已占用') if User.exists?(phone: params[:phone])
            user = "#{params[:type].capitalize}::User".constantize.create(phone: params[:phone],
                        password_md5: params[:password_md5], 
                        nick_name: User.generate_nick_name)

            captcha.update(expire_at: DateTime.current)

            present user, with: API::V1::Entities::Session
          end

        end
      end
    end
  end
