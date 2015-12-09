class Customer < ActiveRecord::Base
  has_many :ports

  validates :account, presence: true, uniqueness: true
  validates_presence_of :name
end
