class CreateBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :batches, id: false, :primary_key => :reference do |t|
      t.string :reference, null: false
      t.string :purchaseChannel
      t.text :orders

      t.timestamps
    end
  end
end
