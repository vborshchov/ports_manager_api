# == Schema Information
#
# Table name: nodes
#
#  id          :integer          not null, primary key
#  name        :string
#  ip          :string
#  location_id :integer
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  model       :string
#  fttb        :boolean          default(FALSE)
#

class Dlink < Node
  require 'net/telnet'

  def get_ports
    @ports_info_arr = []
    host = self.ip
    response = ""
    begin
      tn = Net::Telnet::new(
        "Host" => host,
        "Timeout" => 2,
        "Waittime" => 0.5,
        "Prompt" => /[#>:]/n
      )
      tn.waitfor(/:/) do |banner|
        if banner.match(/UserName/)
          tn.cmd("#{ENV["DLINK_USERNAME"]}\n#{ENV["DLINK_PASSWORD"]}") #{ |c| print c }
          response << tn.cmd("show ports")
          7.times { response << tn.cmd("n") }
          response << tn.cmd("q")
          response << tn.cmd("show vlan")
          response << tn.cmd("a")
          response << tn.cmd("logout")
        end
      end
      tn.close

      @ports_info_arr = parse_log(response)

    rescue Exception => e
      puts "#{e.message} for #{self.name} (#{self.ip})"
    ensure
      
    end

    @ports_info_arr
  end

  # Parsing log file
  def parse_log(response)
    result = []
    lines = []

    response = response.split("\n")
    response.each do |line|
      if line =~ /\d\:\d{1,2}/ || line =~ /Member Ports|VLAN Name/
        lines << line.gsub(/\r/, "").split(/ +/)
      end
    end

    # Make array of hashes with ports attributes
    enum_lines = lines.first(16).to_enum
    (1..8).each do |i|
      port_attributes = {}
      cuper = enum_lines.next
      fiber = enum_lines.next
      port_attributes[:name] = cuper[0]
      state_index = (cuper[-3].to_s + "_").downcase <=> (fiber[-3].to_s + "_").downcase
      port_attributes[:state] = (state_index > 0) ? "up" : "down"
      result << port_attributes
    end

    lines[16..31].each do |line|
      port_attributes = {}
      port_attributes[:name] = line[0]
      port_attributes[:state] = (line[-3].to_s =~ /Down/) ? "down" : "up"
      result << port_attributes
    end

    lines.shift(62)
    description = []
    lines.flatten.slice_before(/VID/).each do |a|
      if a[6] =~ /_/
        description << {name: a[10].split(",")[0], description: a[6]}
      end
    end

    # Find ports with more than one vlan
    names = description.map{|el| el[:name]}
    names = names.select {|e| names.count(e) > 1}.uniq

    # Find repeated hashes and group them by port name
    rep = description.select{|el| names.include? el[:name] }
    rep = rep.group_by{|x| x[:name]}.values

    # Collect all description of each port
    rep.map! do |el|
      desc = []
      port_name = ""
      el.each do |hash|
        desc << hash[:description]
        port_name = hash[:name]
      end
      el = {name: port_name, description: desc.join(", ")}
    end

    #Remove from description array repeated elements
    description_without_repeated_elem = description.select{|hash| names.exclude? hash[:name]}
  
    # Make proper description array
    description = description_without_repeated_elem + rep

    # Merge info about vlans to result array
    description.each do |hash|
      result.map do |port|
        if port[:name] == hash[:name]
          port.merge!(hash)
        end
      end
    end

    result
  end

end
