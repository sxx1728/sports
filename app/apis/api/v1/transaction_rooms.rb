module API
    module V1
      class  TransactionRooms < Grape::API
        resource :transaction_rooms do

          desc '创建一个房间'
          params do
            requires :token, type: String, desc: "user token"
            requires :transaction_id, type: String, desc: "交易id"
            requires :province, type: String, desc: "省份"
            requires :city, type: String, desc: "city"
            requires :district, type: String, desc: "district"
            requires :street, type: String, desc: "street"
            requires :area, type: String, desc: "area"
            requires :detail, type: String, desc: "地址详情"
            requires :owner_relation, type: String, desc: "甲方关系 "
            requires :room_no, type: String, desc: "房屋编号"
            requires :owner_name, type: String, desc: "房主姓名"
            requires :room_usage, type: String, desc: "房屋用途"
            requires :reside_count, type: String, desc: "使用人数"
            requires :is_pledged, type: String, desc: "已抵押"
          end
          post do
            present 1
          end

        end
      end
    end
  end
