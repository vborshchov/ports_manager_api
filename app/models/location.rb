class Location < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :address, :name

  delegate :ciscos, :dlinks, :ztes, to: :nodes
end
