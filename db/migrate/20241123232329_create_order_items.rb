class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.bigint :product_id, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 15, scale: 2, null: false
      t.decimal :total_price, precision: 15, scale: 2, null: false
      t.timestamps
    end
  end
end
