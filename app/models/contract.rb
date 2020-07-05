class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User"
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"

  include AASM
  aasm column: 'state' do
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

  def self.valid_state? state
    self.aasm.states.map(&:name).include?(state.to_sym)
  end

  def summary_desc
    "#{self.trans_monthly_price}#{self.trans_currency}/月"
  end

end
