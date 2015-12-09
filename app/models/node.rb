class Node < ActiveRecord::Base
  require 'snmp'
  # include SNMP

  belongs_to :location
  has_many :ports

  VALID_IPV4_REGEX = /\A(25[0-5]|2[0-4]\d|[1]\d\d|[1-9]\d|[1-9])(\.(25[0-5]|2[0-4]\d|[1]\d\d|[1-9]\d|\d)){3}\z/i
  validates :ip, presence: true, format: { with: VALID_IPV4_REGEX }, uniqueness: true

  scope :ciscos, -> { where(type: 'Cisco') }
  scope :dlinks, -> { where(type: 'Dlink') }
  scope :ztes, -> { where(type: 'Zte') }
end