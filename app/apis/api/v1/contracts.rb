module API
    module V1
      class  Contracts < Grape::API
        resource :contracts do

          desc '我的合同列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :state, type: String, desc: "查找交易的状态[all, unsigned, running, broken, appealed, appealing, arbitrating, finished, canceled]"
            requires :order_by, type: String, desc: "排序类型[time, amount, currency]"
            requires :is_asc, type: Boolean, desc: "是否升序排列"
            requires :page, type: Integer, desc: "页号"
            requires :per_page, type: Integer, desc: "大小"
          end
          get 'index' do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            app_error('无效State', 'invalid state') unless Contract.valid_state?(params[:state] )
            contracts = user.contracts.where(state: params[:state])

            direction = params[:is_asc] ? :asc : :desc
            case params[:order_by]
            when 'time'
              contracts = contracts.order(created_at: direction)
            when 'amount'
              contracts = contracts.order(trans_monthly_price: direction)
            when 'currency'
              contracts = contracts.order(trans_currency: direction)
            end

            contracts = contracts.where(state: params[:state])
            contracts = contracts.paginate(page: params[:page], per_page: params[:per_page])

            present contracts, with: API::V1::Entities::Contracts
          end

          desc '交易更新'
          params do
            requires :token, type: String, desc: "user token"
            requires :id, type: String, desc: "合同ID"
            requires :action, type: String, desc: "合同操作[sign, reject, view, appeal, reply"
          end
          put do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?


            begin
              case params[:action]
              when 'sign'
                contract.sign! user
              when 'reject'
                contract.reject! user
              when 'cancel'
                contract.cancel! user
              else
                app_error('非法操作', 'invalid action')
              end
            rescue AASM::InvalidTransition => e
              app_error(e.message) 
            end
   
            present 'succeed'
          end

          desc '交易详情'
          params do
            requires :token, type: String, desc: "user token"
            requires :id, type: String, desc: "合同ID"
          end
          get do

            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?

            contract = Contract.find params[:id] rescue nil
            app_error('无效合同id', 'id') if contract.nil?

            app_error('无权限') unless user.has_permission?(contract)

            present contract, with: API::V1::Entities::Contract
          end


          desc '创建一个交易'
          params do
            requires :token, type: String, desc: "user token"
            requires :renter_id, type: Integer, desc: "租客ID"
            requires :owner_id, type: Integer, desc: "房东ID"
            requires :room, type: Hash do
              requires :address, type: String, desc: "房屋地址"
              requires :district, type: String, desc: "房屋所在小区"
              requires :area, type: Float, desc: "面积平方米"
              requires :certificate, type: String, desc: "房屋证明资料"
              requires :no, type: String, desc: "房屋证书号码"
              requires :owner_name, type: String, desc: "房主姓名"
              requires :usage, type: String, desc: "房子用途"
              requires :capacity_min, type: Integer, desc: "房子人数最少"
              requires :capacity_max, type: Integer, desc: "房子人数最多"
              requires :is_pledged, type: Boolean, desc: "是否有抵押"
            end
            requires :trans, type: Hash do
              requires :no, type: String, desc: "租赁协议编号"
              requires :currency, type: String, desc: "交易币种"
              requires :monthly_price, type: Float, desc: "月房租"
              requires :pledge_amount, type: Float, desc: "抵押金额"
              requires :payment_type, type: String, desc: "支付模式"
              requires :coupon_code, type: String, desc: "优惠码"
              requires :agency_fee_rate, type: Float, desc: "代理费率"
              requires :agency_fee_by, type: String, desc: "中介费谁支付"
              requires :period, type: Integer, desc: "协议周期月数"
              requires :begin_on, type: Date, desc: "起租日"
              requires :end_on, type: Date, desc: "结束日"
            end
            requires :arbitrators, type: Array[Integer], coerce_with: ->(val) { val.split(/(\s+)|,/).map(&:to_i) }
          end
          post do
            promoter = User.from_token params[:token]
            app_error('无效Token', 401) if promoter.nil?

            renter = Renter::User.find(params[:renter_id]) rescue nil
            app_error('无效房客ID', 'invalid renter id') if renter.nil?

            owner = Owner::User.find(params[:owner_id]) rescue nil
            app_error('无效房东ID', 'invalid owner id') if owner.nil?


            renter = Renter::User.find(params[:renter_id]) rescue nil
            room = params[:room]
            trans = params[:trans]

            arbitrators = Arbitrator::User.where(id: params[:arbitrators])
            app_error('无效仲裁ID', 'invalid arbitrators id') unless arbitrators.size == 5

            room = params[:room]
            trans = params[:trans]

            contract = Contract.new(room_address: room[:address],
                                       room_district: room[:district],
                                       room_area: room[:area],
                                       room_certificate: room[:certificate],
                                       room_no: room[:no],
                                       room_owner_name: room[:owner_name],
                                       room_usage: room[:owner_name],
                                       room_capacity_min: room[:capacity_min],
                                       room_capacity_max: room[:capacity_max],
                                       room_is_pledged: room[:is_pledged],

                                       trans_no: trans[:no],
                                       trans_currency: trans[:currency],
                                       trans_monthly_price: trans[:monthly_price],
                                       trans_pledge_amount: trans[:pledge_amount],
                                       trans_payment_type: trans[:payment_type],
                                       trans_coupon_code: trans[:coupon_code],
                                       trans_agency_fee_rate: trans[:agent_fee_rate],
                                       trans_agency_fee_by: trans[:agent_fee_by],
                                       trans_period: trans[:period],
                                       trans_begin_on: trans[:begin_on],
                                       trans_end_on: trans[:end_on])


            contract.renter = renter;
            contract.owner = owner;
            contract.promoter = promoter;

            contract.arbitrators = arbitrators;
            contract.save
            
            present 'succeed'
          end


        end
      end
    end
  end
