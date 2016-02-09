class PortsWorker
  include Sidekiq::Worker
  include ApplicationHelper
  require 'eventmachine'
  sidekiq_options retry: false

  def perform(node_ids, user)
    start_time = Time.now
    result = update_ports_info(node_ids)

    begin
      EM.run {
        client = Faye::Client.new("http://#{ENV['APP_URL'].chomp}:#{ENV['APP_PORT'].chomp}/faye")
        client.publish('/events', 'message' => notification_text(result, Time.now.to_i - start_time.to_i, user))
      }
    rescue Exception => e
      puts e.message
    end
    begin
      `notify-send "Оновлення інформації про порти" "#{notification_text(result, Time.now.to_i - start_time.to_i, user)}" -i gtk-info`
    end
  end
end