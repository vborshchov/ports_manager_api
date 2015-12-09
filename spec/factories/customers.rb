FactoryGirl.define do
  factory :customer do
    account { 7133000000000000 + (rand 999999) }
    name { FFaker::Company.name }
  end

end
