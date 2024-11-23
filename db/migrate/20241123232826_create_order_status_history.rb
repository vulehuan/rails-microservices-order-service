class CreateOrderStatusHistory < ActiveRecord::Migration[7.2]
  def change
    create_table :order_status_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :note, null: true
      t.timestamps
    end
  end
end
