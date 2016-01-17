namespace :nodes do
  desc "Update information about all ports of all nodes
    or nodes of certain type in the database"
  task :update_ports_of_all, [:model_name, :node_ids] => :environment do |t, args|
    start_time = Time.now
    args.with_defaults(:model_name => "Node", :node_ids => '')
    node_ids_array = args[:node_ids].split(' ').map{ |s| s.to_i }

    model = args[:model_name].capitalize

    node_quantity         = 0
    port_total_quantity   = 0
    port_updated_quantity = 0
    port_created_quantity = 0
    port_passed_quantity  = 0

    if node_ids_array.empty?
      node_total_quantity = model.constantize.all.count
      array = model.constantize.pluck(:id)
    else
      node_total_quantity = node_ids_array.count
      array = model.constantize.pluck(:id) & node_ids_array
    end

    model.constantize.find(array).each do |node|
      begin
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

    begin
      `notify-send "Обновление информации о портах" "Отработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек." -i gtk-info`
    ensure
      puts "-----------------------------------------------------\n#{Time.now}\nОтработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}.\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек."
    end
  end

  task :update_ports_of, [:node_ids] => :environment do |t, args|
    start_time = Time.now
    args.with_defaults(:node_ids => "#{Node.pluck(:id)}")
    node_ids_array = args[:node_ids].split(' ').map{ |s| s.to_i }
    node_total_quantity   = node_ids_array.count
    node_quantity         = 0
    port_total_quantity   = 0
    port_updated_quantity = 0
    port_created_quantity = 0
    port_passed_quantity  = 0
    node_ids_array.each do |node_id|
      node = Node.find_by_id(node_id)
      if node
        ports = node.ports
        gotten_ports = node.get_ports
        unless gotten_ports.empty?
          node_quantity += 1
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
            end
          end
        end
        port_total_quantity += node.ports.count
      end
    end

    begin
      `notify-send "Обновление информации о портах" "Отработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}.\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек.\nid: #{node_ids_array}" -i gtk-info`
    ensure
      puts "\n-----------------------------------------------------#{Time.now}\nОтработано #{node_quantity} комутаторов из #{node_total_quantity},\nпортов:\n    обновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    создано - #{port_created_quantity}.\nВсего портов: #{port_total_quantity + port_created_quantity}.\nЗатраченое время #{(Time.now.to_i - start_time.to_i)/60} мин. #{(Time.now.to_i - start_time.to_i)%60} сек."
    end
  end
end