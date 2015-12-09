class Location < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :address, :name
end
