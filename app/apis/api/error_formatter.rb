module API
  module ErrorFormatter
    def self.call message, backtrace, options, env, original_exception=nil
      if message.is_a? Hash
        {code: message[:code], data: nil, message: message[:tips], success: false }.to_json
      else
        {tips: message}.to_json
      end
    end
  end
end
