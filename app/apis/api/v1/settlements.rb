module API
    module V1
      class  Settlements < Grape::API
        resource :settlements do

          desc '支付账单'
          params do
          end
          post do
            present 1
          end

        end
      end
    end
  end
