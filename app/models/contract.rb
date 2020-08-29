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
  has_many :incomes

  has_many :arbitraments, class_name: "::ContractsUser"

  mount_uploader :pdf, PdfUploader

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

  def generate_pdf()
    Rails.logger.info('begin generate')
    pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')
    tmp_path = Rails.root.join('tmp','contract.pdf')
    Rails.logger.info(tmp_path)
    File.open(tmp_path, 'wb') do |file|
      file << pdf
    end
    
    Rails.logger.info('generated')
    File.open(tmp_path) do |file|
      self.pdf = file
    end
    Rails.logger.info('before save')

    self.save!

  end


  def balance_unpaid()
    if ['unsigned', 'renter_signed', 'owner_signed', 'canceled', 'rejected', 'broken'].include?(self.state)
      0
    else
      total = self.trans_monthly_price * (self.trans_period + self.trans_pledge_amount + self.trans_agency_fee_rate )
      paid = self.bills.where(paid: true).sum(:amount)
      total - paid
    end
  end

  def balance_pledged()
    if ['unsigned', 'renter_signed', 'owner_signed', 'canceled', 'rejected', 'broken'].include?(self.state)
      0
    else
      paid = self.bills.where(paid: true).sum(:amount)
      if paid > 0
        self.trans_monthly_price * self.trans_pledge_amount 
      else
        0
      end
    end
  end

  def balance_rent_fee()
    if ['unsigned', 'renter_signed', 'owner_signed', 'canceled', 'rejected', 'broken'].include?(self.state)
      0
    else
      all = self.bills.where(paid: true).count
      paid = self.incomes.where(item: 'rent-fee').count
      months = all * self.trans_pay_amount - paid
      self.trans_monthly_price * months
    end
  end

  def balance_owner_income()
    if ['unsigned', 'renter_signed', 'owner_signed', 'canceled', 'rejected', 'broken'].include?(self.state)
      0
    else
      paid = self.incomes.where(item: 'rent-fee').sum(:amount)
    end
  end


  def trans_balance()
    all = self.bills.where(paid: true).count
    paid = self.incomes.where(item: 'rent-fee').count
    months = all * self.trans_pay_amount - paid + self.trans_pledge_amount
    self.trans_monthly_price * months

  end

  def create_first_bill()
    block_height = ($eth_client.eth_block_number)['result'] rescue '0x0'
    bill = self.bills.build(item: "房租x#{self.trans_pay_amount} + 押金x#{self.trans_pledge_amount} + 中介费x#{self.trans_agency_fee_rate}",
                                                              amount: self.trans_monthly_price * (self.trans_pay_amount + self.trans_pledge_amount + self.trans_agency_fee_rate),
                                                              paid: false, pay_cycle: 1, block_height: block_height)
    bill.save!
  end

  def release_rent_fee(contract)
    count = self.incomes.where(item: 'rent-fee').where.not(tx_id: nil).count
    pay_count = self.bills.where(paid: true).count * self.trans_pay_amount.to_i
    return if count >= pay_count
    return if pay_count <= 0

    pay_on = self.trans_begin_on + count.months
    return if Date.current < pay_on

    ret = contract.transact_and_wait.release_rent_fee()
    Rails.logger.error(ret)
    if ret.mined?
      scan_rent_income(contract, ret.id)
      Rails.logger.error(ret)
    end

  end



  def scan_promoter_income(contract)

    return if self.promoter.nil?
    return if self.incomes.where(item: 'promoter-fee').exists?
    event_abi = contract.abi.find {|a| a['name'] == 'PromoterFeePaid'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.promoter_fee_paid({
      from_block: '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.promoter_fee_paid(filter_id)
    return if events.count != 1

    event = events[0]
    transaction_id = event[:transactionHash]
    transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

    log = transaction['result']['logs'].detect{ |item|
      item['topics'][0] == "0x1719f634d221d35b40e30f66edbf6124b85fdd0b9ef0f512ceaed896d2d45451"
    }
    return if log.nil?
    data = log['data']
    
    args = $eth_decoder.decode_arguments(event_inputs, data)

    address = args[0]
    unless same_address? self.promoter.eth_wallet_address, address
      Rails.logger.error("contranct promoter address:#{self.promoter.eth_wallet_address} not same as contract event:#{address}")
      return
    end
    tokenAddr = args[2]
    currency = Currency.where(addr: tokenAddr).first
    if currency.nil?
      Rails.logger.error("contract token addr invalid:#{tokenAddr}")
      return
    end


    amount = args[1]
    income = self.incomes.build(user: self.promoter, at: DateTime.current, tx_id: transaction_id, item: 'promoter-fee', amount: amount, currency: currency.name)
    income.save!
  end

  def scan_pledge_income(contract)
    return if self.incomes.where(item: 'pledge-fee').exists?
    event_abi = contract.abi.find {|a| a['name'] == 'RentPledgeReleased'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.rent_pledge_released({
      from_block: '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.rent_pledge_released(filter_id)
    return if events.count != 1

    event = events[0]
    transaction_id = event[:transactionHash]
    transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

    log = transaction['result']['logs'].detect{ |item|
      item['topics'][0] == "0x979d7bf204c4f2d65a9059d99b1dcd279db8e7c6384584e5d29a28fdb4b4d75a"
    }
    return if log.nil?
    data = log['data']
    
    args = $eth_decoder.decode_arguments(event_inputs, data)

    address = args[0]
    unless same_address? self.renter.eth_wallet_address, address
      Rails.logger.error("contranct renter address:#{self.promoter.eth_wallet_address} not same as contract event:#{address}")
      return
    end
    tokenAddr = args[2]
    currency = Currency.where(addr: tokenAddr).first
    if currency.nil?
      Rails.logger.error("contract token addr invalid:#{tokenAddr}")
      return
    end

    amount = args[1]
    income = self.incomes.build(user: self.renter, at: DateTime.current, tx_id: transaction_id, item: 'pledge-fee', amount: amount, currency: currency.name)
    income.save!
  end

  def scan_rent_income(contract, transaction_id)
    event_abi = contract.abi.find {|a| a['name'] == 'RentFeeReleased'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    if transaction_id.nil?
      block_height = self.incomes.where(item: 'rent-fee').order(cycle: :desc).first.try(:block_height) || '0x0'
      block_height = "0x#{(block_height.to_i(16)+1).to_s(16)}"
      filter_id = contract.new_filter.rent_fee_released({
        from_block: block_height,
        to_block: 'latest',
        address: self.chain_address,
      })
      events = contract.get_filter_logs.rent_fee_released(filter_id)
      return if events.empty?
      transaction_id = events[0][:transactionHash]
    end

    transaction = $eth_client.eth_get_transaction_receipt(transaction_id)
    log = transaction['result']['logs'].detect{ |item|
      item['topics'][0] == "0x92779d26a19837706a0aa9ad1d968b5cf152951b31c826299fcb6d2bde543cf7"
    }
      
    return if log.nil?

    data = log['data']
    
    args = $eth_decoder.decode_arguments(event_inputs, data)

    address = args[0]
    ##fix me
    unless same_address? self.owner.eth_wallet_address, address
      Rails.logger.error("contranct owner address:#{self.owner.eth_wallet_address} not same as contract event:#{address}")
      return
    end
    tokenAddr = args[2]
    amount = args[1]
    cycle = self.incomes.where(item: 'rent-fee').count
    income = self.incomes.build(user: self.owner, at: DateTime.current, 
                                tx_id: transaction_id, item: 'rent-fee', 
                                amount: amount.to_f/(10 ** self.currency.decimals), currency: self.currency.name, 
                                block_height: log['blockNumber'], cycle: cycle)
    income.save!

  end


  def scan_running_income()
    unless self.initialized
      Rails.logger.error("contranct is not on_chain: #{self.id}}")
      return 
    end

    contract = self.build_chainly_contract

    scan_promoter_income(contract)
    scan_pledge_income(contract)
    scan_pledge_income(contract)
    scan_rent_income(contract, nil)

    release_rent_fee(contract)
  end
 

  def scan_arbitrament_result()
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationResultGenerated'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_result_generated({
      from_block: '0x0',
      to_block: 'latest',
      address: self.chain_address,
      })
    events = contract.get_filter_logs.arbitration_result_generated(filter_id)

    return if events.count != 1

    event = events[0]
    transaction_id = event[:transactionHash]
    transaction = $eth_client.eth_get_transaction_receipt(transaction_id)

    log = transaction['result']['logs'].detect{ |item|
      item['topics'][0] == "0xcb3e47cde7ae1301b800b024166f8350606b5ced55e601cbcfe585d73f78d2bb"
    }
    return if log.nil?
    data = log['data']
    args = $eth_decoder.decode_arguments(event_inputs, data)

    arbitrament_result = self.arbitrament_result

    paid_event_abi = contract.abi.find {|a| a['name'] =='Paid'}
    paid_event_inputs = paid_event_abi['inputs'].map {|i| OpenStruct.new(i)}

    unless arbitrament_result.present?
      arbitrament_result = self.build_arbitrament_result(owner_rate: args[0], renter_rate: args[1],
                                                         tx_id: transaction_id)
      arbitrament_result.save!

      self.transactions.build(at: DateTime.current, 
                            content: "最终仲裁结果如下：房东:#{arbitrament_result.owner_rate}% #{arbitrament_result.owner_rate/100.0 * self.appeal.amount} #{self.currency.name}, 房客#{arbitrament_result.renter_rate}% #{arbitrament_result.renter_rate/100.0 * self.appeal.amount} #{self.currency.name}", 
                              tx_id: transaction_id).save!

      paid_events = transaction['result']['logs'].select{ |item|
        item['topics'][0] == "0xdad97236b77394a5ee3dd23dd08678094ed216aa89031dd9dfae8d01b9226e89"
      }
      events = paid_events.map{ |item|
        $eth_decoder.decode_arguments(paid_event_inputs, item['data'])
      }
      events.each{ |paid_event|

        addr = "0x#{paid_event[0]}"
        if self.owner.eth_wallet_address.downcase == addr
          amount = paid_event[1].to_f/(10 ** self.currency.decimals)
          self.incomes.build(user: self.owner, at: DateTime.current, tx_id: transaction_id, 
                         item: 'arbitrament-fee', amount: amount, 
                         currency: self.currency.name).save!
        elsif self.renter.eth_wallet_address.downcase == addr
          amount = paid_event[1].to_f/(10 ** self.currency.decimals)
          self.incomes.build(user: self.renter, at: DateTime.current, tx_id: transaction_id, 
                         item: 'arbitrament-fee', amount: amount, 
                         currency: self.currency.name).save!
        else
          arbi = self.arbitrators.detect{ |ar| ar.eth_wallet_address.downcase == addr}
          next if arbi.nil?
          amount = paid_event[1].to_f/(10 ** self.currency.decimals)
          self.incomes.build(user: arbi, at: DateTime.current, tx_id: transaction_id, 
                         item: 'arbitrator-fee', amount: amount, 
                         currency: self.currency.name).save!
        end


     } 
      


   

      self.arbitrate!
    end
  end
   
  def scan_arbitrating()
    contract = self.build_chainly_contract

    event_abi = contract.abi.find {|a| a['name'] =='ArbitrationProposalSubmitted'}
    event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}

    filter_id = contract.new_filter.arbitration_proposal_submitted({
      from_block: self.reply.block_number || '0x0',
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
      next if log.nil?

      data = log['data']
      
      args = $eth_decoder.decode_arguments(event_inputs, data)
      user_address = args[0]
      arbitrament = self.arbitraments.detect{ |some|
        some.tx_id == nil and  same_address?(some.user.eth_wallet_address, user_address)
      }

      next if arbitrament.nil?

      if (args[1].to_i == arbitrament.owner_rate * 10) and (args[2].to_i == arbitrament.renter_rate * 10)
        arbitrament.update!(tx_id: transaction_id, at: DateTime.current)
        transaction = self.transactions.build(at: DateTime.current, 
                                            content: "#{arbitrament.user.desc} 提交仲裁意见, 房东:#{arbitrament.owner_rate}  房客#{arbitrament.renter_rate}", 
                              tx_id: transaction_id)
        transaction.save!
      else
        Rails.logger.error("arbitrament inconsistent on chain: (#{args[1].to_i}, #{args[2].to_i}) vs (#{arbitrament.owner_rate}, #{arbitrament.renter_rate})")
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
      unless log.nil?

        data = log['data']
        args = $eth_decoder.decode_arguments(event_inputs, data)

        user_address = args[0]
        same_address?(reply.user.eth_wallet_address, user_address)
      end
    }

    return if event.nil?

    begin
      self.launch_reply!(reply.user)
      reply.update!(tx_id: event[:transactionHash])
    rescue AASM::InvalidTransition => e
      Rails.logger.error("appeal_id: #{reply.id}, launch appeal faield:#{e.message}")
    end

    transaction = self.transactions.build(at: DateTime.current, 
                                          content: "#{reply.user.desc} 做出答辩", 
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
      binding.pry

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
        self.promoter.try(:eth_wallet_address) || '0x0000000000000000000000000000000000000000',#null promoter set the admin address
        self.currency.addr,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pay_amount).to_i,
        (self.trans_period / self.trans_pay_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_pledge_amount).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_agency_fee_rate).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals) * self.trans_platform_fee_rate).to_i,
        (self.trans_monthly_price * (10 ** self.currency.decimals)).to_i,
        self.trans_begin_on.to_s,
        self.trans_end_on.to_s,
        "押#{self.trans_pledge_amount.to_i}付#{self.trans_pay_amount.to_i}",
        self.arbitrators.map(&:eth_wallet_address))

      binding.pry
      Rails.logger.error(ret)
      if ret.mined
        self.update!(initialized: true)
      else
        Rails.logger.error(result)
      end
 
    end

  end
  
  def self.build_config_contract

    abi = File.read(Rails.root.join(ENV["RENT_CONFIG_ABI"]).to_s)
    contract = Ethereum::Contract.create(client: $eth_client, name: "chainlyrentconfig", address: ENV["RENT_CONFIG_ADDRESS"], abi: abi)
    key = Eth::Key.new(priv:ENV["RENT_ADMIN_KEY"])

    contract.key = key

    contract
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
    when 'running', 'broken', 'arbitrating', 'finished', 'canceled', 'arbitrated'
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
