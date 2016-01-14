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
          response << tn.cmd("logout")
        end
      end
      tn.close

      @ports_info_arr = parse_log(response)

    rescue Exception => e  
      puts e.message  
      puts e.backtrace.inspect
    ensure
      
    end

    @ports_info_arr
  end

  # Parsing log file
  def parse_log(response)
    result = []
    lines = []

    response = response.split("\n")[6..75]
    response.each do |line|
      if line =~ /\d\:\d{1,2}/
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

    result
  end

end
