class CreateBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :batches do |t|
      t.string :reference, null: false
      t.string :purchaseChannel, null: false
      t.text :orders, null: false

      t.timestamps
    end
  end
end
