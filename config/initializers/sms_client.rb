require 'aliyunsdkcore'

$sms_client = RPCClient.new(
  access_key_id:     ENV['RENT_ALIYUN_KEY_ID'],
  access_key_secret: ENV['RENT_ALIYUN_KEY_SECRET'],
  endpoint: ENV['RENT_ALIYUN_SMS_ENDPOINT'],
  api_version: ENV['RENT_ALIYUN_SMS_API_VERSION']
)
