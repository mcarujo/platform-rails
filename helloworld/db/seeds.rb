require 'faker'

20.times do 
    Order.create( reference: "BR" + Faker::Number.number(6), 
        purchaseChannel: Faker::Company.name, 
        clientName: Faker::Name.name, 
        address: Faker::Address.full_address, 
        deliveryService: Faker::Company.name, 
        totalValue: Faker::Number.between(1,101), 
        lineItems: Faker::Json.shallow_json(Faker::Number.between(1,6), key: 'Lorem.word', value: 'Lorem.word'),
        status: [:ready, :production, :closing, :sent].sample 
    )
end

20.times do 
    purchaseChannel = Faker::Company.name
    batch = Batch.new(reference: Faker::Number.number(4) + '-' + Faker::Number.number(2), purchaseChannel: purchaseChannel, orders: Array.new )
    Faker::Number.between(1,6).times do
        order = Order.create(reference: "BR" + Faker::Number.number(6), purchaseChannel: purchaseChannel, clientName: Faker::Name.name, address: Faker::Address.full_address, deliveryService: Faker::Company.name, totalValue: Faker::Number.between(1,101), lineItems: Faker::Json.shallow_json(Faker::Number.between(1,6), key: 'Lorem.word', value: 'Lorem.word'),status: [:ready, :production, :closing, :sent].sample )
        batch.orders << order.id.to_s
    end
    batch.save
end
