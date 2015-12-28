class Dlink < Node
  require 'net/telnet'

  def get_ports
    @ports_info_arr = []
    host = self.ip
    tn = Net::Telnet::new(
      "Host" => host,
      "Timeout" => 25,
      "Waittime" => 0.5,
      "Prompt" => /[#>:]/n,
      "Output_log" => "output_log.txt"
    )
    tn.waitfor(/:/) do |banner|
      if banner.match(/UserName/)
        tn.cmd("#{ENV["DLINK_USERNAME"]}\n#{ENV["DLINK_PASSWORD"]}") #{ |c| print c }
        tn.cmd("show ports")
        7.times { tn.cmd("n") }
        tn.cmd("q")
        tn.cmd("logout")
      end
    end
    tn.close

    # Parsing log file
    file = "output_log.txt"
    lines = []
    if File.exist?(file)
      File.open(file, 'r') do |f|
        f.each_with_index do |line, index|
          if (17..139).include? index
            line = line.gsub(/\r/, "")
            if line =~ /\d\:\d{1,2}/
              lines << line.split(/ +/)
            end
          end
        end
      end
    end

    # Remove unnecessary log file
    system('rm output_log.txt')

    # Make array of hashes with ports attributes
    enum_lines = lines.first(16).to_enum
    (1..8).each do |i|
      port_attributes = {}
      cuper = enum_lines.next
      fiber = enum_lines.next
      port_attributes[:name] = cuper[0]
      state_index = (cuper[-4].to_s + "_").downcase <=> (fiber[-4].to_s + "_").downcase
      port_attributes[:state] = (state_index < 0) ? "up" : "down"
      @ports_info_arr << port_attributes
    end

    lines[16..31].each do |line|
      port_attributes = {}
      port_attributes[:name] = line[0]
      port_attributes[:state] = (line[-4].to_s =~ /Down/) ? "down" : "up"
      @ports_info_arr << port_attributes
    end

    @ports_info_arr
  end

end