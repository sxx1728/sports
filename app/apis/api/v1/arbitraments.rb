module API
    module V1
      class  Arbitraments < Grape::API
        resource :arbitraments do

          desc '创建仲裁相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_code, type: String, desc: "transaction code"
            requires :at, type: DateTime, desc: "submit time"
            requires :cause, type: String, desc: "arbitratment cause"
            requires :stuff_images, type: Array[String], desc: "申诉材料图片列表"
            requires :amount, type: Float, desc: "争议金额"
          end
          post do
            present 1
          end

          desc '查看仲裁相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_code, type: String, desc: "transaction code"
            requires :arbitrament_code, type: String, desc: "arbitrament_code"
          end
          get do
            present 1
          end

          desc '查看仲裁列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :arbitrament_code, type: String, desc: "arbitrament_code"
            requires :status, type: String, desc: "仲裁状态查找"
            requires :order_by, type: String, desc: "排序字段"
            requires :is_asc, type: Boolean, desc: "是否增序"
            requires :page_num, type: Integer, desc: "页号"
            requires :page_size, type: Integer, desc: "每页大小"
          end
          get do
            present 1
          end


        end
      end
    end
  end
