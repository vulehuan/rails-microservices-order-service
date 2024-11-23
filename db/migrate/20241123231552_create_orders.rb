class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.bigint :user_id, null: false
      t.string :order_number, null: false, index: { unique: true }
      t.string :status, null: false, default: "pending"
      t.decimal :total_price, precision: 15, scale: 2, null: false
      t.timestamps
    end

    add_index :orders, [:status, :user_id]
  end
end
