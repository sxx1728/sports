

require 'rufus-scheduler'

require 'ostruct'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

contract_factory = Contract.build_contract_factory
s.every('20s', overlap: false){
  
  Contract.where(state: 'running', is_on_chain: false).each{ |contract|
    contract.deploy(contract_factory)
  }


}

