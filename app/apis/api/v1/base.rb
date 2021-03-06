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

      mount API::V1::Profiles
      mount API::V1::Images
      mount API::V1::Captchas
      mount API::V1::Registrators
      mount API::V1::Arbitrators
      mount API::V1::Bills
      mount API::V1::Kycs
      mount API::V1::Appeals
      mount API::V1::Home
      mount API::V1::Replies
      mount API::V1::Sessions
      mount API::V1::Contracts
      mount API::V1::Arbitraments
      mount API::V1::ArbitramentResults
      mount API::V1::Currencies
      mount API::V1::Transactions
      mount API::V1::Incomes

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
