class Cisco < Node

  def get_ports
    @ports_arr = []
    host = self.ip
    ifTable_columns = ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifAlias"]
    SNMP::Manager.open(:Host => host, :Community => 'sw3400') do |manager|
      response = manager.get(["sysName.0", "sysUpTime.0"])
      response.each_varbind do |vb|
          puts "#{vb.name.to_s[/(?<=\:{2}).*(?=\.)/].split(/(?=[A-Z])/).join(" ")}  #{vb.value.to_s}"
      end
      manager.walk(ifTable_columns) do |row|
        port_attributes = {name: "", state: "", description: ""}
        state_index = -2 # this id for index in array of states
        row.each do |vb|
          case vb.name.to_s
            when /Desc/
              port_attributes[:name] = vb.value.to_s
            when /AdminStatus|OperStatus/
              state_index += vb.value.to_s.to_i
            when /Alias/
              port_attributes[:description] = vb.value.to_s
          end
          port_attributes[:state] = Port::STATES[state_index]
        end
        @ports_arr << port_attributes
      end
    end
    puts @ports_arr
  end

  def update_ports_info
  end
end