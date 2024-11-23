class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :payment_method, null: false
      t.string :payment_status, null: false, default: "pending"
      t.string :transaction_id, null: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.datetime :paid_at
      t.timestamps
    end
  end
end
