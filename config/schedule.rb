RAILS_ROOT = File.dirname(__FILE__) + '/..'
set :output, "#{RAILS_ROOT}/log/cron_log.log"

every 1.day, at: '23:30' do
  rake "nodes:update_ports"
end

every :month, at: '23:20' do
  # command "rm #{RAILS_ROOT}/log/*.log"
end

# Learn more: http://github.com/javan/whenever