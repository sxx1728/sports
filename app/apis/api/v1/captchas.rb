module API
    module V1
      class  Captchas < Grape::API
        resource :captchas do

          desc '发送手机验证码'
          params do
            requires :phone, type: String, desc: "phone number to receive the captcha"
          end
          post do

            app_error('无效电话', 'invalid phone') unless Captcha.valid_phone? params[:phone]

            captcha = Captcha.where(phone: params[:phone]).where("expire_at > ?", DateTime.current).last
            if captcha.present?
              present 'succeed'
            end
            captcha = Captcha.create(phone: params[:phone])
            present 'succeed'
          end

        end
      end
    end
  end
