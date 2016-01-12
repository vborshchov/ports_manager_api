class Iskratel < Node
  require 'net/telnet'

  def get_ports
    @ports_info_arr = []
    host = self.ip
    begin
      tn = Net::Telnet::new(
        "Host" => host,
        "Timeout" => 1,
        "Waittime" => 0.5,
        "Prompt" => /[#>:]/n,
        "Output_log" => "output_log.txt"
      )
      tn.waitfor(/:/) do |banner|
        if banner.match("ISKRATEL Switching")
          tn.cmd("guest\n\n") #{ |c| print c }
          tn.cmd("show port all")
          tn.cmd("show vlan port all")
          tn.cmd("show vlan brief")
          tn.cmd("logout")
        end
      end
      tn.close

      @ports_info_arr = parse_log("output_log.txt")

    rescue Exception => e  
      puts e.message  
      puts e.backtrace.inspect
    ensure
      # Remove unnecessary log file
      system('rm output_log.txt')
    end
    @ports_info_arr

  end

  # Parsing log file
  def parse_log(file)
    lines = []
    if File.exist?(file)
      File.open(file, "r") do |f|
        f.each do |line|
          lines << line.chomp
        end
      end
    end
    names_and_states = []
    port_vlans = []
    vlan_names = []
    lines.shift(7)
    arr = lines
            .reject(&:empty?)
            .slice_before(/ISKRATEL/)
            .to_a
    arr.pop
    (arr[0] - arr[0].shift(4)).each do |line|
      match = line.match(/^([01]\/\d{1,2}).*(Enable|Disable).*(Up|Down)/)
      state = match[2] == "Enable" ? match[3].downcase : "admin down"
      names_and_states << {name: match[1], state: state}
    end
    
    (arr[1] - arr[1].shift(4)).each do |line|
      port_vlans << [line.match(/^([01]\/\d{1,2}).*?(\d{1,4})/)[1..2]].to_h
    end
    port_vlans = port_vlans.reduce({}, :merge)

    (arr[2] - arr[2].shift(4)).each do |line|
      vlan_names << [line.match(/^(\d{1,4}) {4,7}(\w+|)/)[1..2]].to_h
    end
    vlan_names = vlan_names.reduce({}, :merge)

    port_vlans = port_vlans.each { |k,v| port_vlans[k] = ["VLAN", port_vlans[k], vlan_names[v]].join(" ").strip}
    names_and_states.map do |hash|
      hash.merge({description: port_vlans[hash[:name]].to_s})
    end
  end
end