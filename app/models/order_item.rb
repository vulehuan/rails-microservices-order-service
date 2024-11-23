# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order

  validates :quantity, presence: true
  validates :unit_price, presence: true
  validates :total_price, presence: true

  before_save :calculate_total_price

  private

  def calculate_total_price
    self.total_price = quantity * unit_price
  end
end
