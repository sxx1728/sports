# frozen_string_literal: true

class Admins::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  include GoogleAuthenticator
  # GET /resource/sign_up
  def new
    super {
      resource.google_secret = generate_secret_key
      qrcode = RQRCode::QRCode.new("otpauth://totp/Example:alice@google.com?secret=#{resource.google_secret}&issuer=Example", level: :h)
      qrcode_png = qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 120,
        border_modules: 4,
        module_px_size: 6,
        file: nil # path to write
      )
      @qrcode_img = "data:image/png;base64,#{Base64.strict_encode64(qrcode_png.to_s)}"
    }
  end

  # POST /resource
  def create
    unless sign_up_params[:password] =~ /(?=.*[`~!@#$^&*()=|{}':;',\[\].<>\/?~])(?=.*\w)(?=.*\d)/
      redirect_back(fallback_location: new_admin_registration_path, alert: 'Invalid password') 
      return
    end

    super {
      resource.google_secret = params.require(:admin).permit![:google_secret]
      resource.save
    }
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
