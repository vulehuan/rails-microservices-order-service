# frozen_string_literal: true

class PaymentSerializer < ActiveModel::Serializer
  attributes :payment_method, :payment_status, :transaction_id, :amount, :paid_at
end
