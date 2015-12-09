FactoryGirl.define do
  factory :location do
    name { FFaker::Lorem.word }
    address { FFaker::Address.street_address }
  end

end
