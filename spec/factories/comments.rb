FactoryGirl.define do
  factory :comment do
    body {FFaker::Lorem.sentence}
    user nil
    port nil
  end

end
