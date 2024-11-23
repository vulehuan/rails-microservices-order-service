# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :order

  validates :amount, presence: true
  validates :payment_method, presence: true
  validates :payment_status, presence: true

  enum payment_status: { pending: 'pending', completed: 'completed', failed: 'failed' }

  before_create :set_default_payment_status

  private

  def set_default_payment_status
    self.payment_status ||= 'pending'
  end
end
