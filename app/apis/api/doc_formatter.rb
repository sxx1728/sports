
module API
  module DocFormatter
    def self.call object, env
      object.to_json
    end
  end
end


