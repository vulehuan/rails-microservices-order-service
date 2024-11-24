# frozen_string_literal: true

class OrderCollectionSerializer < ActiveModel::Serializer
  attributes :id, :order_number, :status, :recipient_name, :recipient_phone, :created_at, :updated_at
end
