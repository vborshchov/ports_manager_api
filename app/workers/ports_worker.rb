class PortsWorker
  require "pusher"
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(node_ids)
    start_time = Time.now
    node_total_quantity   = node_ids.count
    node_quantity         = 0
    port_total_quantity   = 0
    port_updated_quantity = 0
    port_created_quantity = 0
    port_passed_quantity  = 0

    node_ids.each do |id|
      begin
        node = Node.find(id)
        ports = node.ports
        port_total_quantity += ports.count
        gotten_ports = node.get_ports
        next if gotten_ports.empty?
        gotten_ports.zip(ports).each do |pair|
          # pair[0] - ports's attributes reseived from node
          # pair[1] - existing port's attributes
          if pair[1] # if port exist do
            pair[1].assign_attributes(pair[0])
            if pair[1].changed? && pair[1].save
              port_updated_quantity += 1
            else
              port_passed_quantity += 1
            end
          else # if port does not exist create new port
            port = Port.new(pair[0].merge({node_id: node.id}))
            port.save
            port_created_quantity += 1
            port_total_quantity += 1
          end
        end
        node_quantity += 1
      rescue
        next
      end
    end

    url = "https://PUSHER_KEY:PUSHER_SECRET@api.pusherapp.com/apps/PUSHER_APP_ID"
    Pusher.url = url

    begin
      `notify-send "Оновлення інформації про порти" "Оброблено #{node_quantity} комутаторів з #{node_total_quantity},\nВсього #{port_total_quantity} портів:\n    оновлено - #{port_updated_quantity}\n    створено - #{port_created_quantity}.\nВитрачено часу #{(Time.now.to_i - start_time.to_i)/60} хв. #{(Time.now.to_i - start_time.to_i)%60} сек." -i gtk-info`
      Pusher.trigger("ports_updater", "report", {notification_text: "Оброблено #{node_quantity} комутаторів з #{node_total_quantity},\nВсього #{port_total_quantity} портів:\n  __оновлено - #{port_updated_quantity}\n  __створено - #{port_created_quantity}.\nВитрачено часу #{(Time.now.to_i - start_time.to_i)/60} хв. #{(Time.now.to_i - start_time.to_i)%60} сек."})
    rescue Pusher::Error => e
      puts e
    end
  end
end