class UpdateIndexOnOrders < ActiveRecord::Migration[7.2]
  def change
    remove_index :orders, name: "index_orders_on_status_and_user_id"
    add_index :orders, [:created_at, :status, :user_id], name: "index_orders_on_created_at_and_status_and_user_id"
    add_index :orders, [:updated_at, :status, :user_id], name: "index_orders_on_updated_at_and_status_and_user_id"
  end
end
