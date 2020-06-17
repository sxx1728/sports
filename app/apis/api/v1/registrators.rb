module API
    module V1
      class  Registrators < Grape::API
        resource :registrators do

          desc '新用户注册'
          params do
            requires :phone, type: String, desc: "phone number"
            requires :captcha, type: String, desc: "captcha"
            requires :type, type: String, desc: "phone type"
          end
          post do
            app_error('无效类型', 'invalid type') unless User.valid_type? params[:type]
            app_error('无效电话', 'invalid phone') unless Captcha.valid_phone? params[:phone]
            app_error('无效验证码', 'invalid captcha') unless Captcha.valid_captcha? params[:captcha]
            app_error('验证码错误', 'captcha incorrect') unless Captcha.where(phone: params[:phone], captcha: params[:captcha])
              .where("expire_at > ?", DateTime.current).exist?
            Captcha.where(phone: params[:phone], captcha: params[:captcha]).where("expire_at > ?", DateTime.current)
              .update_all(expire_at: DateTime.current)

            User.create(phone: params[:phone],
                        type: params[:type]



                                                                    



            present 1
          end

        end
      end
    end
  end
