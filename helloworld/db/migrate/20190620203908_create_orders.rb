class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders, id: false, :primary_key => :reference do |t|
      t.string :reference
      t.string :purchaseChannel
      t.string :clientName
      t.string :address
      t.string :deliveryService
      t.float :totalValue
      t.text :lineItems
      t.string :status

      t.timestamps
    end
  end
end
