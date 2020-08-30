module API
    module V1
      class  Captchas < Grape::API
        resource :captchas do

          desc '发送手机验证码'
          params do
            requires :phone, type: String, desc: "phone number to receive the captcha"
          end
          post do

            app_error('无效电话' ) unless Captcha.valid_phone? params[:phone]
            captcha = Captcha.where(phone: params[:phone]).last
            app_error('发送频繁，请稍候调用') if captcha.present? and captcha.created_at + 30.seconds > DateTime.current

            captcha = Captcha.where(phone: params[:phone]).where("expire_at > ?", DateTime.current).last

            unless captcha.present?
              captcha = Captcha.create(phone: params[:phone])
            end
            present captcha.send_sms
          end

        end
      end
    end
  end
