require 'ostruct'

class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User"
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"
  belongs_to :currency
  has_many :bills
  has_one :appeal
  has_one :reply
  has_many :transactions

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
      transitions from: :unsigned, to: :renter_signed, guard: Proc.new {|user| 
        self.renter == user
      }
      transitions from: :unsigned, to: :owner_signed, guard: Proc.new {|user|
        self.owner == user 
      }
      transitions from: :renter_signed, to: :running, guard: Proc.new {|user| 
        self.owner == user 
      }
      transitions from: :owner_signed, to: :running, guard: Proc.new {|user|
        self.renter == user
      }
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

  def create_first_bill()
    bill = self.bills.build(item: "房租x#{self.trans_pay_amount} + 押金x#{self.trans_pledge_amount} + 中介费x#{self.trans_agency_fee_rate}",
                                                              amount: self.trans_monthly_price * (self.trans_pay_amount + self.trans_pledge_amount + self.trans_agency_fee_rate),
                                                              paid: false)
    bill.save!
  end

  
  def deploy(factory)
    if self.chain_address.nil?
      ret = factory.transact_and_wait.new_rent_contract(ENV["RENT_CONFIG_ADDRESS"])
      if ret.mined
        tx_id = ret.id
      else
        Rails.logger.error("new_rent_contract failed") 
        return
      end

      event_abi = factory.abi.find {|a| a['name'] == 'RentContractCreated'}
      event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

      transaction = $eth_client.eth_get_transaction_receipt(tx_id)

      data = transaction['result']['logs'][0]['data'] rescue nil
      unless data.present?
        Rails.logger.error("Get transaction data failed: #{transaction}") 
        return
      end

      args = $eth_decoder.decode_arguments(event_inputs, data)
      unless args.present? and args.size() == 2
        Rails.logger.error("Decode transaction data failed: #{transaction}") 
        return
      end

      self.update!(chain_address: args[0])

    end

    unless self.is_on_chain
      contract = self.build_chainly_contract
      binding.pry
      ret = contract.transact_and_wait.init(
        self.id.to_s,
        self.owner.eth_wallet_address,
        self.renter.eth_wallet_address,
        self.promoter.eth_wallet_address,
        self.currency.addr,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pay_amount).to_i,
        (self.trans_period / self.trans_pay_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pledge_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_agency_fee_rate).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals)).to_i,
        self.trans_begin_on.to_s,
        self.trans_end_on.to_s,
        "押#{self.trans_pledge_amount}付#{self.trans_pay_amount}",
        self.arbitrators.map(&:eth_wallet_address))

      Rails.logger.error(ret)
      if ret.mined
        self.update!(is_on_chain: true)
      else
        Rails.logger.error(result)
      end
 
    end

  end
  

  def self.build_contract_factory

    abi = File.read(Rails.root.join(ENV["RENT_FACTORY_ABI"]).to_s)
    contract = Ethereum::Contract.create(client: $eth_client, name: "contractfactory", address: ENV["RENT_FACTORY_ADDRESS"], abi: abi)
    key = Eth::Key.new(priv:ENV["RENT_ADMIN_KEY"])

    contract.key = key

    contract
  end

  def build_chainly_contract

    abi = File.read(Rails.root.join(ENV["RENT_CONTRACT_ABI"]).to_s)
    contract = Ethereum::Contract.create(client: $eth_client, name: "contract", address: self.chain_address,  abi: abi)

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
