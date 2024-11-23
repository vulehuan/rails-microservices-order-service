# frozen_string_literal: true

class OrderStatusHistory < ApplicationRecord
  belongs_to :order

  validates :status, presence: true

  enum status: { pending: 'pending', completed: 'completed', canceled: 'canceled', shipped: 'shipped', delivered: 'delivered' }
end
