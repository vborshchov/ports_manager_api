# == Schema Information
#
# Table name: nodes
#
#  id          :integer          not null, primary key
#  name        :string
#  ip          :string
#  location_id :integer
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  model       :string
#  fttb        :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :node do
    name { "ck-" + FFaker::Lorem.word + "-router" }
    ip { FFaker::Internet.ip_v4_address }
    location
    type { ["cisco", "dlink", "zte"].sample }
  end

end
