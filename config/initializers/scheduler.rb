

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

contract_factory = Contract.build_contract_factory

s.every('1m', overlap: false){
  
  Contract.where(state: 'running').where(is_on_chain: false).each{ |contract|
    Rails.logger.info('Deploying')
    contract.deploy(contract_factory)
  }


}

s.every('1m', overlap: false){
  
  Contract.where(state: 'running').where(is_on_chain: true).each{ |contract|
    
    bill_count = contract.bills.count
    if bill_count == 0
      Rails.logger.error('First bill')
      contract.create_first_bill()
    else
      Rails.logger.error('Scan paid bill')
      contract.scan_chain_bill()

    end
  }


}


