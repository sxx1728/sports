module API
  module V1
    module Entities
      class Contract < Grape::Entity
        include API::Helpers

        expose :trans_no

        expose :room_address
        expose :room_district
        expose :room_area
        expose :room_certificate

        expose :room_usage
        expose :room_capacity_min
        expose :room_capacity_max
        expose :room_is_pledged

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

        expose :trans_currency
        expose :trans_monthly_price
        expose :trans_amount_pledge
        expose :trans_coupon_code
        expose :trans_coupon_rate
        expose :trans_agency_fee_rate
        expose :trans_agency_fee_rate_origin
        expose :trans_agency_fee_by
        expose :trans_period
        expose :trans_begin_on
        expose :trans_end_on

        expose :state

        expose :arbitrators, using: API::V1::Entities::Arbitrators do |m,o|
          m.arbitrators
        end
      end
    end
  end
end