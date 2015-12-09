FactoryGirl.define do
  factory :port do
    name { ["Gi0/",""].sample + (rand(37)+1).to_s }
    state { ["admin down", "down", "up"].sample }
    description { FFaker::Lorem.sentence }
    node_id nil
    customer_id nil
    reserved false
  end

end
