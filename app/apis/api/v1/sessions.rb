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

          app_error('无效电话', 'invalid phone') unless Captcha.valid_phone? params[:phone]
          app_error('无效密码', 'password_md5 incorrect') unless params[:password_md5].present?
          app_error('无效用户或密码错误', 'password_md5 incorrect') unless User.exists?(phone: params[:phone], password_md5: params[:password_md5])
          user = User.where(phone: params[:phone], password_md5: params[:password_md5]).first
          app_error('无效用户或密码错误', 'password_md5 incorrect') unless user.present?

          present user, with: API::V1::Entities::Session
        end

        desc '用户修改密码'
        params do
          requires :token, type: String, desc: "user token"
          requires :old_password_md5, type: String, desc: "用户密码MD5"
          requires :new_password_md5, type: String, desc: "用户密码MD5"
        end
        put do
          app_error('无效旧密码', 'invalid old password') if params[:old_password_md5].blank?
          app_error('无效新密码', 'invalid new password') if params[:new_password_md5].blank?
          app_error('新密码不能跟老密码一致', 'invalid new password same as old') if params[:new_password_md5] == params[:old_password_md5]

          user = User.from_token params[:token]

          app_error('无效Token', 'invalid token') if user.nil?
          app_error('错误旧密码', 'incorrect old password') unless user.password_md5 == params['old_password_md5']

          user.update!(password_md5: params[:new_password_md5])

          present 'succeed'
        end


      end
    end
  end
end

