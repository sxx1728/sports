
module API
  module Helpers

    

    def app_error message, code=400, location=request.path
      error!({code: code, message: message, location: location}, 200)
    end

    def server_error message, code=500, location=request.path
      error!({code: code, message: message, location: location}, 200)
    end

  end
end

