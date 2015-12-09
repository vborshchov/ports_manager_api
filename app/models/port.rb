# == Schema Information
#
# Table name: ports
#
#  id          :integer          not null, primary key
#  name        :string
#  state       :string
#  description :string
#  node_id     :integer
#  customer_id :integer
#  reserved    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Port < ActiveRecord::Base
  belongs_to :node
  belongs_to :customer
  has_many :comments

  validates :name, :state, presence: true

  STATES = ["up", "down", "admin down"]
end
