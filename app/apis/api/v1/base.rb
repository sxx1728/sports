require 'grape-swagger'
module API
  module V1
    class Base < Grape::API

      version 'v1', :path
      helpers API::Helpers
      formatter :json, API::JsonFormatter
      error_formatter :json, API::ErrorFormatter

      content_type :json, 'application/json; charset=utf8'
      content_type :xml, "text/xml"
      content_type :txt, "text/plain"

      default_format :json

      mount API::V1::Captchas
      mount API::V1::Registrators
      mount API::V1::Appeals
      mount API::V1::Arbitraments
      mount API::V1::Home
      mount API::V1::Payments
      mount API::V1::Replies
      mount API::V1::Sessions
      mount API::V1::Settlements
      mount API::V1::TransactionLogs
      mount API::V1::Transactions

      namespace :doc do
        
        formatter :json, API::DocFormatter
        add_swagger_documentation
      end


      get :hello do
        'xxxx'
      end
    end
  end
end
