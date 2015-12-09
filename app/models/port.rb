class Port < ActiveRecord::Base
  belongs_to :node
  belongs_to :customer
  has_many :comments

  validates :name, :state, presence: true
end
