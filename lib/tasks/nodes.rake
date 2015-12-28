namespace :nodes do
  desc "Update information about all ports of all nodes in database"
  task update_ports_info: :environment do
    start_time = Time.now
    node_total_quantity = Node.all.count
    port_total_quantity = Port.all.count
    port_quantity = 0
    node_quantity = 0
    Node.all.each do |node|
      ports = node.ports
      begin
        node.get_ports.zip(ports).each do |pair|
          if pair[1]
            pair[1].update_attributes(pair[0])
          else
            port = Port.new(pair[0].merge({node_id: node.id}))
            port.save
          end
        end
        port_quantity++
        node_quantity++
      rescue
        next
      end
    end

    `notify-send "Обновление информации о портах" "Отработано #{node_quantity} комутаторов из #{node_total_quantity},\nобновлено #{port_quantity} из #{port_total_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек." -i gtk-info`
    puts "Отработано #{node_quantity} комутаторов из #{node_total_quantity},\nобновлено #{port_quantity} из #{port_total_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек."
  end
end