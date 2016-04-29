class Huawei < Node
  require 'net/telnet'

  def get_ports
    if self.model =~ /S2328P/
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
          if banner.match(/UserName/i)
            tn.cmd("#{ENV['DLINK_USERNAME']}\n#{ENV['ZTE_PASSWORD']}") #{ |c| print c }
            response << tn.cmd("display interface")
            35.times { response << tn.cmd(" ") }
            tn.cmd("quit")
          end
        end
        tn.close

        @ports_info_arr = parse_log(response)

      rescue Exception => e
        puts "#{e.message} for #{self.name} (#{self.ip})"
        puts e.backtrace.inspect
      ensure
      
      end

      @ports_info_arr
    end
  end

  # Parsing log file
  def parse_log(response)
    result = []
    lines = []

    response = response.split("\n")
    response.each do |line|
      if line =~ /current state/ || line =~ /Description/
        lines << line.split(/ *: */)
      end
    end

    # Make array of hashes with ports attributes
    enum_lines = lines.first(3*28).to_enum
    (1..28).each do |i|
      port_attributes = {}
      port = enum_lines.next
      port_name = port[0]
      port_state = port[1]
      line_state = enum_lines.next[1]
      port_description = enum_lines.next[1]

      port_attributes[:name] = port_name.match(/\S+(?=\s)/)[0]
      state_index = (port_state.to_s + "_").downcase <=> (line_state.to_s + "_").downcase
      case state_index
      when 1
        port_attributes[:state] = 'down'
      when 0
        port_attributes[:state] = port_state.to_s.downcase
      when -1
        port_attributes[:state] = 'unknown'
      end
      port_attributes[:description] = port_description =~ /HUAWEI/ ? '' : port_description
      result << port_attributes
    end

    result
  end
end
