# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ActiveRecord::Base
  has_many :nodes
  validates_presence_of :address, :name
  delegate :ciscos, :dlinks, :ztes, to: :nodes
end
