FactoryGirl.define do
  factory :node do
    name { "ck-" + FFaker::Lorem.word + "-router" }
    ip { FFaker::Internet.ip_v4_address }
    location
    type { ["cisco", "dlink", "zte"].sample }
  end

end
