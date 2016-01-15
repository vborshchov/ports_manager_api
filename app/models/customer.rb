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

  validates :account, presence: true, uniqueness: true, format: { with: /\A71\d{14}\z/ }
  validates_presence_of :name

  scope :with_ports, -> { where("id IN (SELECT customer_id FROM ports)") }

  # def self.with_ports
  #   @nodes = self.includes(:ports).references(:ports).where.not('ports.id IS NULL')
  # end

end
