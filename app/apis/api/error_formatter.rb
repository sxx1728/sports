module API
  module ErrorFormatter
    def self.call message, backtrace, options, env, original_exception=nil
      case original_exception.class
      when Grape::Exceptions::ValidationErrors
        {code: 400, data: nil, message: message}.to_json
      else
        if message.is_a? Hash
          {code: message[:code], data: nil, message: message[:message], success: false }.to_json
        else
          {code: 500, data: nil, message: message}.to_json
        end
      end
   end
  end
end
