module API
    module V1
      class  Replies < Grape::API
        resource :replies do

          desc '答辩相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :arbitrament_id, type: String, desc: "arbitrament id"
            requires :at, type: DateTime, desc: "reply at"
            requires :cause, type: String, desc: "Replay cause"
            requires :stuff_images, type: Array[String], desc: "答辩材料图片列表"
            requires :amount, type: Float, desc: "争议金额"
          end
          post do
            present 1
          end

        end
      end
    end
  end
