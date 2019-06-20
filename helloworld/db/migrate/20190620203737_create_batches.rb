class CreateBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :batches do |t|
      t.string :reference
      t.string :purchaseChannel
      t.text :orders

      t.timestamps
    end
  end
end
