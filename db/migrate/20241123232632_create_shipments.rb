class CreateShipments < ActiveRecord::Migration[7.2]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :shipment_status, null: false, default: "pending"
      t.string :carrier
      t.string :tracking_number
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.timestamps
    end
  end
end
