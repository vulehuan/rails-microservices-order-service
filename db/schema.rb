# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_24_021629) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 15, scale: 2, null: false
    t.decimal "total_price", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "order_status_histories", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "status", default: "pending", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_status_histories_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending", null: false
    t.decimal "total_price", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shipping_address_line1", null: false
    t.string "shipping_address_line2"
    t.string "shipping_city", null: false
    t.string "shipping_state"
    t.string "shipping_zip_code"
    t.string "shipping_country", null: false
    t.string "recipient_name", null: false
    t.string "recipient_phone", null: false
    t.text "order_notes"
    t.text "admin_notes"
    t.index ["created_at", "status", "user_id"], name: "index_orders_on_created_at_and_status_and_user_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["updated_at", "status", "user_id"], name: "index_orders_on_updated_at_and_status_and_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "payment_method", null: false
    t.string "payment_status", default: "pending", null: false
    t.string "transaction_id"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "shipment_status", default: "pending", null: false
    t.string "carrier"
    t.string "tracking_number"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_status_histories", "orders"
  add_foreign_key "payments", "orders"
  add_foreign_key "shipments", "orders"
end
