class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User"
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"
  has_many :bills
  has_one :appeal
  has_one :reply
  has_many :transactions
  belongs_to :coin

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
      transitions from: :renter_signed, to: :running, guard: Proc.new {|user| self.owner == user }
      transitions from: :owner_signed, to: :running, guard: Proc.new {|user| self.renter == user }
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
        }
      transitions from: :running, 
        to: :owner_appealed, 
        guard: Proc.new {|user, appeal_tx_id| 
          self.owner == user 
        } 
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

  def deploy(factory)
    if self.tx_id.nil?
      ret = factory.transact_and_wait.new_rent_contract(ENV["RENT_CONFIG_ADDRESS"])
      if ret.mined
        self.update!(tx_id: ret.id)
      else
        Rails.logger.error(result)
        return
      end
    end

    unless  self.is_on_chain
      contract = self.build_chainly_contract
      contract.transact_and_wait.init(
        self.id.to_s,
        self.eth.wallet_address,
        self.owner.address



    end




     
  end
  

  def self.build_contract_factory

    abi = File.read(Rails.root.join(ENV["RENT_FACTORY_ABI"]).to_s)
    contract = Ethereum::Contract.create(client: $client, name: "contractfactory", address: ENV["RENT_FACTORY_ADDRESS"], abi: abi)
    key = Eth::Key.new(priv:ENV["RENT_ADMIN_KEY"])

    contract.key = key

    contract
  end

  def build_chainly_contract

    abi = File.read(Rails.root.join(ENV["RENT_CONTRACT_ABI"]).to_s)
    contract = Ethereum::Contract.create(client: $client, name: "contract", address: self.tx_id,  abi: abi)



    key = Eth::Key.new(priv:ENV["RENT_ADMIN_KEY"])
    contract.key = key
    contract
  end




  def log_transaction_renter_appeal
    content = "房客(#{self.renter.nickanme} ID: #{self.renter.id}), 发起申诉 "
    transaction = self.build_transaction(at: DateTime.current, content: content)
    transaction.save! 
  end

  def log_transaction_owner_appeal
    content = "房东(#{self.renter.nickanme} ID: #{self.renter.id}), 发起申诉 "
    transaction = self.build_transaction(at: DateTime.current, content: content)
    transaction.save! 
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

end
