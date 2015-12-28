namespace :nodes do
  desc "Update information about all ports of all nodes in database"
  task update_ports_info: :environment do
    Zte.all.each do |node|
      ports = node.ports
      begin
        node.get_ports.zip(ports).each do |pair|
          puts pair[0]
          puts pair[1]
          if pair[1]
            pair[1].update_attributes(pair[0])
          else
            port = Port.new(pair[0].merge({node_id: node.id}))
            port.save
          end
        end
      rescue
        next
      end
    end
  end
end