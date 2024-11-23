# frozen_string_literal: true

class Shipment < ApplicationRecord
  belongs_to :order

  validates :shipment_status, presence: true
  validates :carrier, presence: true
  validates :tracking_number, presence: true, if: :shipped?

  enum shipment_status: { pending: 'pending', shipped: 'shipped', delivered: 'delivered' }

  before_update :update_delivered_at

  private

  def update_delivered_at
    if status == 'delivered' && delivered_at.nil?
      self.delivered_at = Time.current
    end
  end
end
