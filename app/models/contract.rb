class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User"
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"
  has_many :bills
  has_one :appeal
  has_one :reply

  has_many :arbitrament, class_name: "ContractsUsers"

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

    event :launch_reply do
      transitions from: :renter_appealed, 
        to: :arbitrating, 
        guard: Proc.new {|user|
          self.owner == user 
        }
      transitions from: :owner_appealed, 
        to: :arbitrating, 
        guard: Proc.new {|user| 
          self.renter == user
        }
    end
 
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

  def state_desc user
    case self.state
    when 'running', 'broken', 'arbitrating', 'finished', 'canceled'
      return self.state
    when 'unsigned', 'renter_signed', 'owner_signed'
      return 'unsigned'
    when 'renter_appealed'
      if user.type == 'Renter::User' 
        return 'appealing'
      elsif user.type == 'Owner::User'
        return 'appealed'
      else
        return 'none'
      end
    when 'onwer_appealed'
      if user.type == 'Renter::User' and 
        return 'appealed'
      elsif user.type == 'Owner::User'
        return 'appealing'
      else
        return 'none'
      end
    else 
      return 'none'
    end

  end

  def check_appeal_tx_id? appeal_tx_id
    true
  end

end
