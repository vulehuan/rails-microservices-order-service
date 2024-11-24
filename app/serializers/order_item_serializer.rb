# frozen_string_literal: true

class OrderItemSerializer < ActiveModel::Serializer
  attributes :product_id, :quantity, :unit_price, :total_price
end
