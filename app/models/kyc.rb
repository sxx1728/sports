class Kyc < ApplicationRecord

  belongs_to :user
  
  belongs_to :front_img, class_name: "Image"
  belongs_to :back_img, class_name: "Image"

  include AASM
  aasm column: 'state' do
    state :verifing, initial: true
    state :accepted
    state :rejected
  end


end





