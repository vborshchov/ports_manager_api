set :output, "/home/victor/sh/ports_manager_cron/cron_log.log"

every 1.day, at: '23:30' do
  rake "nodes:update_ports"
end

# Learn more: http://github.com/javan/whenever