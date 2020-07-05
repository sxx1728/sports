
module API
  module JsonFormatter
    def self.call object, env
      {code: 200, data: object, message: '操作成功', success: true}.to_json
    end
  end
end


