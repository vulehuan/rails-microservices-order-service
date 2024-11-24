require 'rails_helper'

RSpec.describe "Error Handling", type: :request do
  let(:admin_token) { jwt_token_for('admin', 1) }
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{admin_token}" } }

  describe "Handling unexpected errors" do
    it "sends exceptions to Sentry" do
      allow(Order).to receive(:all).and_raise(StandardError, "Unexpected error")

      expect(Sentry).to receive(:capture_exception).with(kind_of(StandardError))

      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:internal_server_error)
    end

    it "sends RecordNotFound exceptions to Sentry" do
      allow(Order).to receive(:find).and_raise(ActiveRecord::RecordNotFound)

      expect(Sentry).to receive(:capture_exception).with(kind_of(ActiveRecord::RecordNotFound))

      get "/api/v1/orders/9999", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Record not found")
    end

    it "sends RecordInvalid exceptions to Sentry" do
      allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Order.new))

      expect(Sentry).to receive(:capture_exception).with(instance_of(ActiveRecord::RecordInvalid))
      post "/api/v1/orders",
           params: { order: { order_number: "" } }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Invalid record")
    end
  end
end
