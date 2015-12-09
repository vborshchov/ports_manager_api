FactoryGirl.define do
  factory :comment do
    body {FFaker::Lorem.sentence}
    users nil
    ports nil
  end

end
