module API
    module V1
      class  Contracts < Grape::API
        resource :contracts do

          desc '我的合同列表'
          params do
            requires :token, type: String, desc: "user token"
            requires :state, type: String, values: ['all', 'unsigned', 'running', 'broken', 'appealed', 'appealing', 'arbitrating', 'finished', 'canceled'], desc: "查找交易的状态"
            requires :order_by, type: String, desc: "排序类型[time, amount, currency]"
            requires :is_asc, type: Boolean, desc: "是否升序排列"
            requires :page, type: Integer,  desc: "页号" 
            requires :per_page, type: Integer, values: 1..50, desc: "大小"
          end
          get 'index' do
            user = User.from_token params[:token]
            app_error('无效Token', 401) if user.nil?
            contracts = user.contracts

            direction = params[:is_asc] ? :asc : :desc
            case params[:order_by]
            when 'time'
              contracts = contracts.order(created_at: direction)
            when 'amount'
              contracts = contracts.order(trans_monthly_price: direction)
            when 'currency'
              contracts = contracts.order(trans_currency: direction)
            end

            case params[:state]
            when 'all'
              contracts = contracts
            when 'running', 'broken', 'arbitrating', 'finished', 'canceled'
              contracts = contracts.where(state: params[:state])
            when 'unsigned'
              contracts = contracts.where(state: ['unsigned', 'renter_signed', 'owner_signed'])
            when 'appealed'
              if user.type == 'Renter::User'
                contracts = contracts.where(state: 'owner_appealed')
              elsif user.type == 'Owner::User'
                contracts = contracts.where(state: 'renter_appealed')
              else
                contracts = contracts.where(state: 'invalid')
              end
            when 'appealing'
              if user.type == 'Renter::User'
                contracts = contracts.where(state: 'renter_appealed')
              elsif user.type == 'Owner::User'
                contracts = contracts.where(state: 'owner_appealed')
              else
                contracts = contracts.where(state: 'invalid')
              end
            else 
              app_error('无效State', 'invalid state')
            end
            contracts = contracts.paginate(page: params[:page], per_page: params[:per_page])

            present :contracts, contracts, with: API::V1::Entities::Contracts, user: user

            present :pages, contracts.total_pages
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

            present contract, with: API::V1::Entities::Contract, user: user
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
              requires :currency, type: String, desc: "交易币种[ETH]"
              requires :monthly_price, type: Float, desc: "月房租"
              requires :pledge_amount, type: Float, desc: "抵押几个月"
              requires :pay_amount, type: Float, desc: "一次支付几个月"
              optional :coupon_code, type: String, desc: "优惠码"
              requires :agency_fee_by, type: String, desc: "中介费谁支付"
              requires :period, type: Integer, desc: "租赁总月数, 必须是支付每次支付月数的整数倍"
              requires :begin_on, type: Date, desc: "起租日"
              requires :end_on, type: Date, desc: "结束日"
            end
            requires :arbitrators, type: Array[Integer], coerce_with: ->(val) { val.split(/(\s+)|,/).map(&:to_i) }
          end
          post do
            promoter = User.from_token params[:token]
            app_error('无效Token', 401) if promoter.nil?
            app_error('无权创建合同') unless ['Promoter::User', 'Owner::User'].include?(promoter.type)
            app_error('中介钱包地址不能为空 ') if promoter.eth_wallet_address.nil?

            renter = Renter::User.find(params[:renter_id]) rescue nil
            app_error('无效房客ID') if renter.nil?
            app_error('租客钱包地址不能为空 ') if renter.eth_wallet_address.nil?

            owner = Owner::User.find(params[:owner_id]) rescue nil
            app_error('无效房东ID') if owner.nil?
            app_error('房东钱包地址不能为空 ') if owner.eth_wallet_address.nil?

            if owner == promoter
                promoter = nil
            end

            room = params[:room]
            trans = params[:trans]

            currency = Currency.where(name: trans[:currency]).first rescue nil
            app_error('无效币种名称') if currency.nil?


            arbitrators = Arbitrator::User.where(id: params[:arbitrators])
            app_error('无效仲裁ID, 最少5人') unless arbitrators.size == 5
            app_error('仲裁人没有设置钱包地址, 无法参与仲裁') if arbitrators.where(eth_wallet_address: nil).any?

            app_error('租赁总月数不能被单次付费整除') unless trans[:period] % trans[:pay_amount] < 0.00001

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
                                       trans_monthly_price: trans[:monthly_price],
                                       trans_pledge_amount: trans[:pledge_amount],
                                       trans_pay_amount: trans[:pay_amount],
                                       trans_coupon_code: trans[:coupon_code],
                                       trans_agency_fee_by: trans[:agency_fee_by],
                                       trans_period: trans[:period],
                                       trans_begin_on: trans[:begin_on],
                                       trans_end_on: trans[:end_on])

            if trans[:coupon_code].present?
              coupon = Coupon.where(code: trans[:coupon_code]).first
              app_error('中介费优惠券无效') if coupon.nil?
              contract.trans_agency_fee_rate_origin = 0.025;
              contract.trans_agency_fee_rate = contract.trans_agency_fee_rate_origin - coupon.coupon_rate;
            else
              contract.trans_agency_fee_rate_origin = 0.025;
              contract.trans_agency_fee_rate = contract.trans_agency_fee_rate_origin;
            end

            contract.renter = renter;
            contract.owner = owner;
            contract.promoter = promoter;

            contract.arbitrators = arbitrators;
            contract.currency = currency;

            contract.save!


            
            present contract.id
          end


        end
      end
    end
  end
