class AddShippingInfoToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :shipping_address_line1, :string, null: false
    add_column :orders, :shipping_address_line2, :string, null: true, default: nil
    add_column :orders, :shipping_city, :string, null: false
    add_column :orders, :shipping_state, :string, null: true
    add_column :orders, :shipping_zip_code, :string, null: true
    add_column :orders, :shipping_country, :string, null: false
    add_column :orders, :recipient_name, :string, null: false
    add_column :orders, :recipient_phone, :string, null: false
    add_column :orders, :order_notes, :text, null: true
    add_column :orders, :admin_notes, :text, null: true
  end
end
