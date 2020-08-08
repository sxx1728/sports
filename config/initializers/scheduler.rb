

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

contract_factory = Contract.build_contract_factory

s.every('1m', overlap: false){

  
  Contract.where(state: 'running').where(initialized: false).each{ |contract|
    Rails.logger.info('Deploying')
    contract.deploy(contract_factory)
  }

 
  Contract.where(state: 'running').where(initialized: true).each{ |contract|
    
    #scan bill
    bill_count = contract.bills.count
    if bill_count == 0
      Rails.logger.error('First bill')
      contract.create_first_bill()
    else
      Rails.logger.error('Scan paid bill')
      contract.scan_chain_bill()
      contract.scan_running_income()
    end
  }

  #scan appeals
  Appeal.where(tx_id: nil).each{ |appeal|
    next unless appeal.contract.running?

    Rails.logger.error('Scan appeal event')
    appeal.contract.scan_appeal(appeal)
  }

  #scan replies
  Reply.where(tx_id: nil).each{ |reply|
    contract = reply.contract
    next unless (contract.renter_appealed? or  contract.owner_appealed?)

    Rails.logger.error('Scan reply event')
    contract.scan_reply(reply)
  }

  Contract.where(state: 'arbitrating').each{ |contract|

    #scan arbitrament
    arbitrating_count = contract.arbitraments.where(tx_id: nil).count
    if arbitrating_count > 0
      Rails.logger.error('scan arbitrating')
      contract.scan_arbitrating()
    end

    arbitrated_count = contract.arbitraments.where.not(tx_id: nil).count
    if arbitrated_count >= 3
      Rails.logger.error('scan arbitrament result')
      contract.scan_arbitrament_result()
    end
  }

  Contract.where(state: 'arbitrated').each{ |contract|
    contract.scan_running_income()
  }

}


