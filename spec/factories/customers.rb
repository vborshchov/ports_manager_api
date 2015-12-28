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

FactoryGirl.define do
  factory :customer do
    account { 7133000000000000 + (rand 999999) }
    name { FFaker::Company.name }
  end

end
