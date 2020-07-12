module API
  module V1
    class  Sessions < Grape::API
      resource :sessions do

        desc '用户登录'
        params do
          requires :phone, type: String, desc: "phone number"
          requires :password_md5, type: String, desc: "password_md5, salt: rent-{password}-{phone}"
        end
        post do

          app_error('无效电话') unless Captcha.valid_phone? params[:phone]
          app_error('无效密码') unless params[:password_md5].present?
          app_error('无效用户或密码错误') unless User.exists?(phone: params[:phone], password_md5: params[:password_md5])
          user = User.where(phone: params[:phone], password_md5: params[:password_md5]).first
          app_error('无效用户或密码错误') unless user.present?

          present user, with: API::V1::Entities::Session
        end

        desc '用户快捷登录'
        params do
          requires :phone, type: String, desc: "phone number"
          requires :captcha, type: String, desc: "默认123456，但是需要先调用captcha发送接口"
        end
        post 'fast' do
          app_error('无效电话') unless Captcha.valid_phone? params[:phone]
          app_error('无效验证码') unless Captcha.valid_captcha? params[:captcha]
          app_error('验证码错误') unless Captcha.where(phone: params[:phone], captcha: params[:captcha]).exists?
          captcha = Captcha.where(phone: params[:phone], captcha: params[:captcha]).last;

          app_error('验证码已过期') unless captcha.expire_at >  DateTime.current

          user = User.where(phone: params[:phone]).first
          app_error('无效用户') unless user.present?
          captcha.update(expire_at: DateTime.current)
          present user, with: API::V1::Entities::Session
        end


        desc '用户修改密码'
        params do
          requires :token, type: String, desc: "user token"
          requires :old_password_md5, type: String, desc: "用户密码MD5"
          requires :new_password_md5, type: String, desc: "用户密码MD5"
        end
        put do
          app_error('无效旧密码') if params[:old_password_md5].blank?
          app_error('无效新密码') if params[:new_password_md5].blank?
          app_error('新密码不能跟老密码一致') if params[:new_password_md5] == params[:old_password_md5]

          user = User.from_token params[:token]

          app_error('无效Token', 401) if user.nil?
          app_error('错误旧密码') unless user.password_md5 == params['old_password_md5']

          user.update!(password_md5: params[:new_password_md5])

          present 'succeed'
        end


      end
    end
  end
end

