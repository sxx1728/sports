class Income < ApplicationRecord
  belongs_to :contract
  belongs_to :user

  def item_desc
    case self.item
    when 'renter-fee'
      '房租'
    when 'promoter-fee'
      '中介费'
    when 'pledge-fee'
      '押金'
    when 'arbitrament-fee'
      '仲裁金额'
    else 
      '未知'
    end
  end
end
