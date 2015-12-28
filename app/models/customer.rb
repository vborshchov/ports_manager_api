# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  account    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Customer < ActiveRecord::Base
  has_many :ports

  validates :account, presence: true, uniqueness: true
  validates_presence_of :name
end
