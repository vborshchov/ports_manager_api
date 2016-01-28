class PortsWorker
  require "pusher"
  include Sidekiq::Worker
  include ApplicationHelper
  sidekiq_options retry: false

  def perform(node_ids, user)
    start_time = Time.now
    result = update_ports_info(node_ids)

    url = "https://#{ENV["PUSHER_KEY"]}:#{ENV["PUSHER_SECRET"]}@api.pusherapp.com/apps/#{ENV["PUSHER_APP_ID"]}"
    Pusher.url = url

    begin
      Pusher.trigger("ports_updater", "report", {notification_text: notification_text(result, Time.now.to_i - start_time.to_i)})
    rescue Pusher::Error => e
      puts e.message
    end
    begin
      `notify-send "Оновлення інформації про порти" "#{notification_text(result, Time.now.to_i - start_time.to_i, user)}" -i gtk-info`
    end
  end
end