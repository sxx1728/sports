class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User"
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"
  has_many :bills
  has_one :appeal

  include AASM
  aasm column: 'state' do
    state :unsigned, initial: true
    state :renter_signed
    state :owner_signed
    state :running
    state :rejected
    state :broken
    state :renter_appealed
    state :owner_appealed
    state :arbitrating
    state :finished
    state :canceled

    event :sign do
      transitions from: :unsigned, to: :renter_signed, guard: Proc.new {|user| self.renter == user }
      transitions from: :unsigned, to: :owner_signed, guard: Proc.new {|user| self.owner == user }
      transitions from: :renter_signed, to: :signed, guard: Proc.new {|user| self.owner == user }
      transitions from: :owner_signed, to: :signed, guard: Proc.new {|user| self.renter == user }
    end
    event :reject do
      transitions from: [:unsigned, :renter_signed, :owner_signed], to: :rejected
    end
    event :cancel do
      transitions from: [:unsigned, :renter_signed, :owner_signed], to: :canceled, guard: Proc.new {|user| self.promoter == user }
    end
    event :launch_appeal do
      transitions from: :running, 
        to: :renter_appealed, 
        guard: Proc.new {|user, appeal_tx_id|
          self.renter == user
        },
        after: Proc.new {|user, appeal_tx_id| self.build_appeal(tx_id: appeal_tx_id, user: user, at: DateTime.current).save! }
      transitions from: :running, 
        to: :owner_appealed, 
        guard: Proc.new {|user, appeal_tx_id| 
          self.owner == user
        },
        after: Proc.new {|user, appeal_tx_id| self.build_appeal(tx_id: appeal_tx_id, user: user, at: DateTime.current).save! }
 
    end
 
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

  def check_appeal_tx_id? appeal_tx_id
    true
  end



end
