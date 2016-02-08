class NotificationController < FayeRails::Controller
  channel '/events' do
    monitor :subscribe do
      puts "Client #{client_id} subscribed to #{channel} #{Time.now}."
    end
    monitor :unsubscribe do
      puts "Client #{client_id} unsubscribed from #{channel} #{Time.now}."
    end
#    monitor :publish do
#      puts "Client #{client_id} published #{data.inspect} to #{channel}."
#    end
  end
end