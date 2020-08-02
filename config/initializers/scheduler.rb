

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

contract_factory = Contract.build_contract_factory

s.every('20s', overlap: false){

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
    end
  }

  #scan appeals
  Appeal.where(tx_id: nil).each{ |appeal|
    next unless appeal.contract.running?

    Rails.logger.error('casn appeal event')
    contract.scan_appeal(appeal)
  }

}


