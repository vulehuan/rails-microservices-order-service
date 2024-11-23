# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_one :shipment, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :total_price, presence: true

  enum status: { pending: 'pending', completed: 'completed', canceled: 'canceled' }

  before_create :set_default_status

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
