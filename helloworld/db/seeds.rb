require 'faker'
include OrdersHelper
include BatchesHelper

100.times do 
    Order.create( 
        reference: definePKOrders(), 
        purchaseChannel: Faker::Company.name, 
        clientName: Faker::Name.name, 
        address: Faker::Address.full_address, 
        deliveryService: Faker::Company.name, 
        totalValue: Faker::Number.between(1,101), 
        lineItems: Faker::Json.shallow_json(Faker::Number.between(1,6), key: 'Lorem.word', value: 'Lorem.word'),
        status: [:ready, :production, :closing, :sent].sample 
    )
end

50.times do 
    purchaseChannel = Faker::Company.name
    deliveryService = Faker::Company.name
    batch = Batch.new(reference: definePKBatches(), purchaseChannel: purchaseChannel, orders: [] )
    aux = []
    Faker::Number.between(1,6).times do
        order = Order.create(
                reference: definePKOrders(), 
                purchaseChannel: purchaseChannel, 
                clientName: Faker::Name.name, 
                address: Faker::Address.full_address, 
                deliveryService: deliveryService, 
                totalValue: Faker::Number.between(1,101), 
                lineItems: Faker::Json.shallow_json(Faker::Number.between(1,6), key: 'Lorem.word', value: 'Lorem.word'), 
                status: [:ready, :production, :closing, :sent].sample
            )
        aux << order.reference
    end
    batch.orders = aux.to_json
    batch.save
end
