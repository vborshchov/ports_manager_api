require 'ffaker'

def random_item_id(className, probability=1)
  if  probability > 0 && probability <= 1
    class_ids = className.capitalize.constantize.ids
    (class_ids + Array.new((class_ids.length * (1 - probability)).to_i)).sample
  end
end

# Locations
location_ck =  Location.create(name: "АТС 36-37", address: "м. Черкаси, вул. Байди Вишневецького, 34")
location_ck_71_73 =  Location.create({name: "АТС 71-73", address: "м. Черкаси, вул. Гоголя, 534"})
location_sm =  Location.create({name: "АТС-3", address: "м.Сміла Лобачевського 1а"})

#Routers
router1 = Node.create(name: "ck-cherkasy-ats-36-37-c-3400-ds", ip: "192.168.252.10", location_id: location_ck.id)
router2 = Node.create(name: "ck-cherkasy-ats-71-73-c-3400-ds", ip: "192.168.252.30", location_id: location_ck_71_73.id)
router3 = Node.create(name: "ck-cherkasy-c-3400-ds", ip: "192.168.255.248", location_id: location_ck.id)
router4 = Node.create(name: "ck-smila-ats-3-c-3400-ds", ip: "192.168.253.30", location_id: location_sm.id)

#Customer
(1..3).each do |i|
  Customer.create(name: FFaker::Company.name, account: 7133000000000000 + (rand 999999))
end


# Ports
Node.ids.each do |id|
  (1..16).each do |i|
    Port.create(name: "Gi0/#{i}", node_id: id, state: ["admin down", "down", "up"].sample, description: FFaker::Lorem.sentence, customer_id: random_item_id("customer", 0.1))
  end
end

#User
16.times{ User.create(email: FFaker::Internet.email, password: "12345678", password_confirmation: "12345678", auth_token: Time.now.to_i.to_s) }

#Comments
30.times {Comment.create(body: FFaker::Lorem.sentence, port_id: random_item_id("port"), user_id: random_item_id("user"))}