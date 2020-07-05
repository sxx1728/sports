

require 'rufus-scheduler'

require 'ostruct'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'
