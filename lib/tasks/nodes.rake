namespace :nodes do
  desc "Update information about all ports of all nodes in database"
  task update_ports_info: :environment do
    start_time = Time.now
    node_total_quantity = Node.all.count
    port_total_quantity = Port.all.count
    port_updated_quantity = 0
    port_created_quantity = 0
    node_quantity         = 0
    port_passed_quantity  = 0
    Node.all.each do |node|
      ports = node.ports
      begin
        node.get_ports.zip(ports).each do |pair|
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
          end
        end
        node_quantity += 1
      rescue
        next
      end
    end

    begin
      `notify-send "Обновление информации о портах" "Отработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек." -i gtk-info`
    ensure
      puts "Обновление информации о портах\nОтработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}.\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек."
    end
  end
end