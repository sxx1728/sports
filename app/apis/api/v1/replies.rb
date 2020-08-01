module API
    module V1
      class  Replies < Grape::API
        resource :replies do

          desc '查看答辩相关信息'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: String, desc: "transaction code"
          end
          get do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?

            app_error('用户无权限') unless  contract.renter == user or contract.owner == user or contract.arbitrators.include?(user)

            present contract.reply, with: API::V1::Entities::Reply
          end




          desc '创建答辩相关'
          params do
            requires :token, type: String, desc: "user token"
            requires :contract_id, type: String, desc: "transaction code"
            requires :images, type: Array[Integer], coerce_with: ->(val) { 
              val.split(/\D+/).select(&:present?).map(&:to_i) 
            },  desc: "答复图片"
            requires :reply, type: String, desc: "答复理由"
          end
          post do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:contract_id] rescue nil
            app_error('无效合同id') if contract.nil?

            app_error('无效合同状态') unless ((contract.renter_appealed? and user.type == 'Owner::User') or 
                                          (contract.owner_appealed? and user.type == 'Renter::User'))

            if contract.reply.nil?
              block_number = ($eth_client.eth_block_number)['result'] rescue '0x0'
              reply = contract.build_reply(reply: params[:reply], user: user, at: DateTime.current, 
                                          block_number: block_number)
            else
              reply = contract.reply
              reply.update(reply: params[:reply], user: user, at: DateTime.current)
            end

            images = params[:images].map{|img_id|
              img = Image.find(img_id) rescue nil
              app_error('图像ID无效') if img.nil? || img.user != user
              img_id
            }
            reply.images = images
            reply.save!

            begin
              contract.launch_reply!(user)
            rescue AASM::InvalidTransition => e
              app_error(e.message)
            end


            present contract.reply, with: API::V1::Entities::Reply
          end



        end
      end
    end
  end
