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

class Zte < Node
  require 'net/telnet'

  def get_ports
    if self.model =~ /2936/ && self.ip != "10.168.253.60"
      super
    else
      port_number = self.model.match(/.*(\d{2})/)[1]
      zte_model = self.model.match(/(?<=ZXR10)-*(\d{4})/)[1]
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
          zte_model_regex = Regexp.new("#{zte_model}|ZTE")
          if banner.match(zte_model_regex)
            tn.cmd("#{ENV['ZTE_USERNAME']}\n#{ENV['ZTE_PASSWORD']}") do |output|
              if output.match(/failure/)
                tn.cmd("#{ENV['ZTE_USERNAME']}\n#{ENV['ZTE_NEW_PASSWORD']}") #{ |c| print c }
              end
            end
            port_number.to_i.times do |i|
              port = zte_model =~ /5250/ ? "1/#{i+1}" : i+1
              response << tn.cmd("show port #{port}")
              response << tn.cmd(" ")
            end
            response << tn.cmd("n")
            response << tn.cmd("n")
            response << tn.cmd("exit")
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
  end

  # Parsing log file
  def parse_log(response)
    lines = []
    response
        .split("\n")
        .reject(&:empty?)
        .each do |line|
          case line
            when /PortId|PortName|Description|PortEnable/
              lines << line.match(/[A-Z]\w+(?= *:) *: (\S+)\s*/)[1]
            when /Link/
              lines << line.match(/(?<=Link           : )(\w+)/)[1]
          end
        end
    lines
        .slice_before(/\A1*\/*\d{1,2}\z/)
        .map do |id, name="", description="", port_enable, link|
          state = port_enable == "enabled" ? link : "admin down"
          {name: id, description: [name, description].compact.reject(&:empty?).join("|"), state: state}
        end
  end
end
