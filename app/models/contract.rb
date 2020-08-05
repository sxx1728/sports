require 'ostruct'
require 'utils'

class Contract < ApplicationRecord

  include Utils

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
      transitions from: [:unsigned, :renter_signed, :owner_signed], to: :canceled, guard: Proc.new {|user| self.promoter == user || self.owner == user}
    end
    event :launch_appeal do
      transitions from: :running, 
        to: :renter_appealed, 
        guard: Proc.new {|user|
          self.renter == user
        }
      transitions from: :running, 
        to: :owner_appealed, 
        guard: Proc.new {|user| 
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
    block_height = ($eth_client.eth_block_number)['result'] rescue '0x0'
    bill = self.bills.build(item: "房租x#{self.trans_pay_amount} + 押金x#{self.trans_pledge_amount} + 中介费x#{self.trans_agency_fee_rate}",
                                                              amount: self.trans_monthly_price * (self.trans_pay_amount + self.trans_pledge_amount + self.trans_agency_fee_rate),
                                                              paid: false, pay_cycle: 1, block_height: block_height)
    bill.save!
  end

  def scan_arbitrament_result()
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationResultGenerated'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_data_submitted({
      from_block: '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.arbitration_result_generated(filter_id)

    events.each{ |event|
      transaction_id = event[:transactionHash]
      transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

      log = transaction['result']['logs'].detect{ |item|
        item['topics'][0] == "0xcb3e47cde7ae1301b800b024166f8350606b5ced55e601cbcfe585d73f78d2bb"
      }
      next if log.nil?
      data = log['data']
      
      args = $eth_decoder.decode_arguments(event_inputs, data)

      arbitrament_result = self.arbitrament_result

      unless arbitrament_result.present?
        arbitrament_result = self.build_arbitrament_result(owner_rate: args[0], renter_rate: args[1],
                                                           tx_id: transaction_id)
        arbitrament_result.save!

        transaction = self.transactions.build(at: DateTime.current, 
                                              content: "最终仲裁结果如下：房东:#{arbitrament_result.owner_rate}% #{arbitrament_result.owner_rate/100.0 * self.appeal.amount} #{self.currency.name}  ,房客#{arbitrament_result.renter_rate}% #{arbitrament_result/100.0 * self.appeal.amount} #{self.currency.name}", 
                                tx_id: transaction_id)
        transaction.save!

        self.arbitrate!
      else
        Rails.logger.error("arbitrament inconsistent on chain: (#{args[1].to_i}, #{args[2].to_i}) vs (#{arbitrament.owner_rate}, #{arbitrament.renter_rate})")
      end
    }
  end
   
  def scan_arbitrating()
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationProposalSubmitted'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_data_submitted({
      from_block: '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.arbitration_proposal_submitted(filter_id)

    events.each{ |event|
      transaction_id = event[:transactionHash]
      transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

      log = transaction['result']['logs'].detect{ |item|
        item['topics'][0] == "0x4bd75e3dd1ce1ee16eac7d60271c123a291a08d52602dcc026bfdb0fcd984983"
      }
      data = log['data']
      
      args = $eth_decoder.decode_arguments(event_inputs, data)

      user_address = args[0]
      arbitrament = self.arbitraments.detect{ |some|
        some.user.eth_wallet_address == user_address
      }

      if arbitrament.present?

        if (args[1].to_i == arbitrament.owner_rate) and (args[2].to_i == arbitrament.renter_rate)
          arbitrament.update!(tx_id: transaction_id)

          transaction = self.transactions.build(at: DateTime.current, 
                                              content: "#{arbitrament.user.desc} 提交仲裁意见, 房东:#{arbitrament.owner_rate}  房客#{arbitrament.renter_rate}", 
                                tx_id: transaction_id)
          transaction.save!
        else
          Rails.logger.error("arbitrament inconsistent on chain: (#{args[1].to_i}, #{args[2].to_i}) vs (#{arbitrament.owner_rate}, #{arbitrament.renter_rate})")
        end
      end
    }
  end
   
  def scan_reply(reply)
    unless self.initialized
      Rails.logger.error("contranct is not on_chain: #{self.id}}")
      return 
    end
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationDataSubmitted'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_data_submitted({
      from_block: reply.block_number,
      to_block: 'latest',
      address: self.chain_address,
      })
    event = contract.get_filter_logs.arbitration_data_submitted(filter_id).detect{ |some|
      transaction_id = some[:transactionHash]
      transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

      log = transaction['result']['logs'].detect{ |item|
        item['topics'][0] == "0x44fa3c47a2ffb313e06ae135667481e7c75ae5cc163222ab899585a546cff81e"
      }
      return false if log.nil?

      data = log['data']
      args = $eth_decoder.decode_arguments(event_inputs, data)

      user_address = args[0]
      return same_address?(reply.user.eth_wallet_address, user_address)
    }

    return if event.nil?

    begin
      contract.launch_reply!(reply.user)
      reply.update!(tx_id: event[:transactionHash])
    rescue AASM::InvalidTransition => e
      Rails.logger.error("appeal_id: #{reply.id}, launch appeal faield:#{e.message}")
    end

    transaction = self.transactions.build(at: DateTime.current, 
                              content: "#{reply.user.desc} 发起答辩, 金额:#{reply.amount} #{self.currency.name}", 
                              tx_id: transaction_id)
    transaction.save!
  end


  def scan_appeal(appeal)
    unless self.initialized
      Rails.logger.error("contranct is not on_chain: #{self.id}}")
      return 
    end
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationDataSubmitted'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_data_submitted({
      from_block: appeal.block_number,
      to_block: 'latest',
      address: self.chain_address,
      })

    event = contract.get_filter_logs.arbitration_data_submitted(filter_id).detect{ |some|
      transaction_id = some[:transactionHash]
      transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

      log = transaction['result']['logs'].detect{ |item|
        item['topics'][0] == "0x44fa3c47a2ffb313e06ae135667481e7c75ae5cc163222ab899585a546cff81e"
      }
      unless log.nil?
        data = log['data']
        args = $eth_decoder.decode_arguments(event_inputs, data)
        user_address = args[0]
        same_address? appeal.user.eth_wallet_address, user_address
      end
   }

    return if event.nil?

    begin
      self.launch_appeal!(appeal.user)
      appeal.update!(tx_id: event[:transactionHash])
    rescue AASM::InvalidTransition => e
      Rails.logger.error("appeal_id: #{ppeal.id}, launch appeal faield:#{e.message}")
    end

    transaction = self.transactions.build(at: DateTime.current, 
                                          content: "#{appeal.user.desc} 发起仲裁, 争议金额:#{appeal.amount} #{self.currency.name}", 
                            tx_id: event[:transactionHash])
    transaction.save!
  end
   

  def scan_chain_bill()
    unless self.initialized
      Rails.logger.error("contranct is not on_chain: #{self.id}}")
      return 
    end

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

      bill.update!(paid: true, tx_id: transaction_id)
      transaction = self.transactions.build(at: DateTime.current, 
                                            content: "#{self.renter.desc} 支付#{bill.item}, 金额:#{amount} #{self.currency.name}", 
                              tx_id: transaction_id)
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

    unless self.initialized
      contract = self.build_chainly_contract
      ret = contract.transact_and_wait.init(
        self.id.to_s,
        self.owner.eth_wallet_address,
        self.renter.eth_wallet_address,
        self.promoter.try(:eth_wallet_address) || ENV['RENT_ADMIN_ADDRESS'],#null promoter set the admin address
        self.currency.addr,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pay_amount).to_i,
        (self.trans_period / self.trans_pay_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pledge_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_agency_fee_rate).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals)).to_i,
        self.trans_begin_on.to_s,
        self.trans_end_on.to_s,
        "押#{self.trans_pledge_amount.to_i}付#{self.trans_pay_amount.to_i}",
        self.arbitrators.map(&:eth_wallet_address))

      Rails.logger.error(ret)
      if ret.mined
        self.update!(initialized: true)
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
