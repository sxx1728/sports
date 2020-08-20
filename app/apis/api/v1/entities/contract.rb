module API
  module V1
    module Entities
      class Contract < Grape::Entity
        include API::Helpers

        expose :trans_no

        expose :room_no
        expose :room_usage
        expose :room_address
        expose :room_district
        expose :room_area
        expose :room_certificate
        expose :room_certificate_owner
        expose :room_capacity_min
        expose :room_capacity_max
        expose :room_is_pledged

        expose :room_promoter_id do |m,o|
          m.promoter.id rescue nil
        end
        expose :room_promoter_name do |m,o|
          m.promoter.kyc.name rescue nil
        end
 
        expose :room_owner_id do |m,o|
          m.owner.id
        end
        expose :room_owner_name do |m,o|
          m.owner.kyc.name rescue nil
        end
        expose :room_renter_id do |m,o|
          m.renter.id
        end
        expose :room_renter_name do |m,o|
          m.renter.kyc.name rescue nil
        end

        expose :trans_currency do|m,o|
          m.currency.name
        end
        expose :trans_pay_amount
        expose :trans_pledge_amount
        expose :trans_monthly_price
        expose :trans_coupon_code
        expose :trans_coupon_rate
        expose :trans_agency_fee_rate
        expose :trans_platform_fee_rate_origin
        expose :trans_agency_fee_by
        expose :trans_period
        expose :trans_begin_on
        expose :trans_end_on

        expose :state do|m, o|
          m.state_desc o[:user]
        end
        expose :raw_state do|m, o|
          m.state
        end
        expose :arbitrators, using: API::V1::Entities::Arbitrators
        expose :chain_address
        expose :trans_balance 
        expose :trans_balance_sheet do
          expose :balance_unpaid
          expose :balance_pledged
          expose :balance_rent_fee
          expose :balance_owner_income
        end
        expose :arbitrating_on_chain do|m,o|
          if m.arbitrating?
            m.arbitraments.where(user: o[:user]).first.try(:tx_id).try(:present?) || false
          else
            false
          end
        end
      end
    end
  end
end

