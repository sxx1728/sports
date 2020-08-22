class Kyc < ApplicationRecord

  belongs_to :user
  
  belongs_to :front_img, class_name: "Image"
  belongs_to :back_img, class_name: "Image"

  include AASM
  aasm column: 'state' do
    state :verifing, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: :verifing, to: :accepted 
    end
    event :reject do
      transitions from: :verifing, to: :rejected
    end
 
  end

  def state_desc
    case self.state
    when 'verifing'
      '待验证'
    when 'accepted'
      '验证通过'
    when 'rejected'
      '驳回'
    else
      '未知'
    end
  end


end





