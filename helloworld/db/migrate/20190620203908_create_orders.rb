class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :reference, null: false
      t.string :purchaseChannel, null: false
      t.string :clientName, null: false
      t.string :address, null: false
      t.string :deliveryService, null: false
      t.float :totalValue, null: false
      t.text :lineItems, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
