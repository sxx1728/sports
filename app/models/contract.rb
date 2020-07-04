class Contract < ApplicationRecord
  has_one :renter, class_name: "Renter::User"
  has_one :owner, class_name: "Renter::User"
  has_one :promoter, class_name: "Promoter::User"
  has_many :arbitrator, class_name: "Arbitrator::User", through: :contract_arbitrators, :source: :arbitrator 
  has_many :contract_arbitrators

  include AASM
  aasm do
    state :unsigned, initial: true
    state :signed
    state :rejected
    state :broken
    state :beAppealed
    state :appealed
    state :arbitrating
    state :ended
    state :canceled
  end

  def state_desc 
    I18n.t("contract.#{self.state}")
  end

  def state_color
    case self.state
    when 'unsigned'
      'yellow'
    when 'signed'
      'green'
    when 'rejected', 'beAppealed'
      'red'
    when 'appealed', 'arbitrating', 'finished', 'canceled'
      'gray'
    end
  end

  def summary_desc
    "#{self.trans_monthly_price}#{self.trans_currency}/月"
  end




end
