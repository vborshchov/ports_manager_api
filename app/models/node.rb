class Node < ActiveRecord::Base
  require 'snmp'
  # include SNMP

  belongs_to :location
  has_many :ports, dependent: :destroy

  VALID_IPV4_REGEX = /\A(25[0-5]|2[0-4]\d|[1]\d\d|[1-9]\d|[1-9])(\.(25[0-5]|2[0-4]\d|[1]\d\d|[1-9]\d|\d)){3}\z/i
  validates :ip, presence: true, format: { with: VALID_IPV4_REGEX }, uniqueness: true

  scope :ciscos, -> { where(type: 'Cisco') }
  scope :dlinks, -> { where(type: 'Dlink') }
  scope :ztes, -> { where(type: 'Zte') }

  rails_admin do
    exclude_fields :created_at, :updated_at
  end

  def get_ports
    @ports_info_arr = []
    host = self.ip
    host_community = (self.class.name == "Cisco") ? "sw3400" : "public"
    ifTable_columns = ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifAlias"]
    begin
      SNMP::Manager.open(:Host => host, :Community => host_community) do |manager|
        response = manager.get(["sysName.0", "sysUpTime.0"])
        response.each_varbind do |vb|
            puts "#{vb.name.to_s[/(?<=\:{2}).*(?=\.)/].split(/(?=[A-Z])/).join(" ")}  #{vb.value.to_s}"
        end
        manager.walk(ifTable_columns) do |row|
          port_attributes = {}
          state_index = -2 # this id for index in array of states
          row.each do |vb|
            case vb.name.to_s
              when /Desc/
                port_attributes[:name] = vb.value.to_s
              when /AdminStatus|OperStatus/
                state_index += vb.value.to_s.to_i
              when /Alias/
                port_attributes[:description] = vb.value unless vb.value == ''
            end
            port_attributes[:state] = Port::STATES[state_index]
          end
          @ports_info_arr << port_attributes
        end
      end

    rescue
      # TODO error response
    end

    @ports_info_arr
  end
end