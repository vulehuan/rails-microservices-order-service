class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :order_number, :status, :shipping_address_line1, :shipping_address_line2,
             :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country,
             :recipient_name, :recipient_phone, :order_notes, :admin_notes, :created_at, :updated_at

  has_many :order_items
  has_one :payment
end
