class Income < ApplicationRecord
  belongs_to :contract
  belongs_to :user

  def item_desc
    case self.item
    when 'rent-fee'
      '房租'
    when 'promoter-fee'
      '中介费'
    when 'pledge-fee'
      '押金'
    when 'arbitrament-fee'
      '合同仲裁金额'
    when 'arbitrator-fee'
      '仲裁手续费'
    else 
      '未知'
    end
  end
end
