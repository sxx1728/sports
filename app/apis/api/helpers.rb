
module API
  module Helpers

    

    def app_error tips, error, code=400, location=request.path, error_message=nil
      error!({code: code, tips: tips, error: error, location: location, error_message: error_message}, 200)
    end

    def server_error tips, error, location=request.path, error_message=nil
      error!({code: 500, tips: tips, error: error, location: location, error_message: error_message}, 200)
    end

    def authenticate_user
      error!({code: 401, 
              tips: "授权失效, 请重新登录!", 
              error: "invalid token", 
              location: "authenticate_user", 
              error_message: ""}, 200) if @params[:token].blank?
      @session_user = User.where(token: @params[:token]).first
      error!({code: 401, 
              tips: "无效用户，请重新登录!", 
              error: "failed to find the user", 
              location: "authenticate_user", 
              error_message: ""}, 200) if @session_user.nil?
    end
  end
end

