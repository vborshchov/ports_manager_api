# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Example:
#
set :output, "/home/victor/sh/ports_manager_cron/cron_log.log"
#
every 2.hours do
  # runner "puts Cisco.some_method"
  rake "nodes:update_ports_of_all"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
