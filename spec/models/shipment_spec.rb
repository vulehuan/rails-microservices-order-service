require 'rails_helper'

RSpec.describe Shipment, type: :model do
  describe '#update_delivered_at' do
    let(:shipment) { create(:shipment, shipment_status: 'pending', delivered_at: nil) }

    context 'when shipment status changes to delivered' do
      it 'sets delivered_at to the current time' do
        travel_to Time.current do
          shipment.update!(shipment_status: 'delivered')
          expect(shipment.delivered_at).to eq(Time.current)
        end
      end
    end

    context 'when shipment status is delivered but delivered_at is already set' do
      it 'does not change delivered_at' do
        delivered_time = 1.day.ago.change(nsec: 0)
        shipment.update!(shipment_status: 'delivered', delivered_at: delivered_time)
        shipment.update!(shipment_status: 'shipped') # Change status back
        shipment.update!(shipment_status: 'delivered') # Re-deliver
        expect(shipment.delivered_at.change(nsec: 0)).to eq(delivered_time)
      end
    end

    context 'when shipment status is not delivered' do
      it 'does not set delivered_at' do
        shipment.update!(shipment_status: 'shipped')
        expect(shipment.delivered_at).to be_nil
      end
    end
  end
end
