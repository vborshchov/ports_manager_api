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

FactoryGirl.define do
  factory :port do
    name { ["Gi0/",""].sample + (rand(37)+1).to_s }
    state { ["admin down", "down", "up"].sample }
    description { FFaker::Lorem.sentence }
    node
    customer
    reserved false
  end

end
