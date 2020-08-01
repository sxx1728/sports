require 'ostruct'

class Contract < ApplicationRecord

  belongs_to :renter, class_name: "Renter::User"
  belongs_to :owner, class_name: "Owner::User"
  belongs_to :promoter, class_name: "Promoter::User", optional: true 
  has_and_belongs_to_many :arbitrators, class_name: "Arbitrator::User"
  belongs_to :currency
  has_many :bills
  has_one :appeal
  has_one :reply
  has_one :arbitrament_result
  has_many :transactions

  has_many :arbitraments, class_name: "::ContractsUser"

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
    state :arbitrated
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
    event :arbitrate do
      transitions from: :arbitrating, to: :arbitrated
    end
 
 
  end

  def trans_balance()

    in_amount = self.bills.where(in_or_out: true).where(paid: true).sum(:amount)
    out_amount = self.bills.where(in_or_out: false).where(paid: true).sum(:amount)
    in_amount - out_amount
  end

  def create_first_bill()
    block_height = $client.eth_block_number rescue '0x'
    bill = self.bills.build(item: "房租x#{self.trans_pay_amount} + 押金x#{self.trans_pledge_amount} + 中介费x#{self.trans_agency_fee_rate}",
                                                              amount: self.trans_monthly_price * (self.trans_pay_amount + self.trans_pledge_amount + self.trans_agency_fee_rate),
                                                              paid: false, pay_cycle: 1, block_height: block_height)
    bill.save!
  end



  def scan_chain_bill()
    unless self.is_on_chain
      Rails.logger.error("contranct is not on_chain: #{self.id}}")
      return 
    end
    contract = self.build_chainly_contract
    bill = self.bills.where(paid: false).order(pay_cycle: :asc).first

    if bill.nil?
      Rails.logger.error("bill is nil: #{self.id}}")
      return 
    end

    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] == 'RentFeeReceived'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.rent_fee_received({
      from_block: bill.block_height || '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.rent_fee_received(filter_id)

    events.each{ |event|
      transaction_id = event[:transactionHash]
      transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

      log = transaction['result']['logs'].detect{ |item|
        item['topics'][0] == "0xaddf648b115305d494727dc7572346d723ba6e98ae2cf48a61f2015f974dff89"
      }
      data = log['data']
      
      args = $eth_decoder.decode_arguments(event_inputs, data)

      pay_cycle = args[2]
      unless pay_cycle == bill.pay_cycle
        Rails.logger.error("pay_cycle: #{pay_cycle}}, bill_cycle:#{bill.pay_cycle}")
        next
      end

      paid_by = args[0]
      currency = Currency.where("addr like '%#{args[3]}'").first
      if currency.nil?
        Rails.logger.error("Currency addr not found: #{args[3]}}")
        next
      end

      if currency.name != self.currency.name
        Rails.logger.error("Currency name incorrect: #{currency.name}}")
        next
      end

      amount = args[1].to_f / (10 ** currency.decimals)

      if bill.amount > amount
        Rails.logger.error("Paid amount incorrect")
        next
      end

      bill.update!(paid: true, tx_id: log['transactionHash'])
      transaction = self.transactions.build(at: DateTime.current, 
                              content: "租户(ID:#{self.renter.id}) 支付#{bill.item}, 金额:#{amount} #{self.trans_currency}", 
                              tx_id: log['transactionHash'])
      transaction.save!


      left_amount = self.trans_period - (self.trans_pay_amount * pay_cycle)
      pay_amount = [self.trans_pay_amount, left_amount].min
      
      if pay_amount > 0
        next_bill = self.bills.build(item: "房租x#{pay_amount}", 
                                   amount: self.trans_monthly_price * pay_amount,
                                   paid: false, pay_cycle: pay_cycle + 1, 
                                   pay_at: DateTime.current,
                                   block_height: log['blockNumber'])
        next_bill.save!
      end

    }
    
    
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
    when 'owner_appealed'
      if user.type == 'Renter::User' 
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
