require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "Api::V1::Orders", type: :request do
  let(:admin_token) { jwt_token_for('admin', 1) }
  let(:user_token) { jwt_token_for('user', 2) }
  let(:user2_token) { jwt_token_for('user', 3) }

  before do
    Order.destroy_all

    @orders = create_list(:order, 15, user_id: 2) do |order|
      order_items = create_list(:order_item, 2, order: order)
      order.update(total_price: order_items.sum(&:total_price))
      create(:order_status_history, order: order, status: "completed")
      create(:payment, order: order, payment_status: "completed")
      create(:shipment, order: order, shipment_status: "shipped")
    end

    @user2_orders = create_list(:order, 10, user_id: 3) do |order|
      order_items = create_list(:order_item, 2, order: order)
      order.update(total_price: order_items.sum(&:total_price))
      create(:order_status_history, order: order, status: "completed")
      create(:payment, order: order, payment_status: "completed")
      create(:shipment, order: order, shipment_status: "shipped")
    end
  end
  let(:admin_headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{admin_token}" } }
  let(:headers) { { 'Content-Type': 'application/json', 'Authorization': "Bearer #{user_token}" } }

  describe "GET /api/v1/orders" do
    context 'when orders exist' do
      before { get '/api/v1/orders', headers: headers }

      it 'returns orders with pagination metadata' do
        expect(json['data'].size).to eq(10) # Default per_page is 10
        expect(json['meta']).to include('page', 'count', 'pages')
        expect(response).to have_http_status(:ok)
      end

      it "does not include order_notes in the response" do
        expect(json['data'].first).not_to have_key('order_notes')
      end
    end

    context 'when fetching a specific page' do
      before { get '/api/v1/orders?page=2&per_page=5', headers: headers }

      it 'returns correct orders for the page' do
        expect(json['data'].size).to eq(5)
        expect(json['meta']['page']).to eq(2)
        expect(response).to have_http_status(:ok)
      end
    end

    it "allows user to only see their own orders" do
      get "/api/v1/orders?page=1&per_page=100", headers: headers
      expect(response).to have_http_status(:ok)

      returned_ids = json['data'].map { |order| order['id'] }
      expected_ids = @orders.select { |order| order.user_id == 2 }.map(&:id)
      expect(returned_ids).to match_array(expected_ids)
    end
  end

  describe 'GET /api/v1/orders/:id' do
    context 'when the order exists' do
      before { get "/api/v1/orders/#{@orders.first.id}", headers: headers }

      it 'returns the order' do
        expect(json['data']['id']).to eq(@orders.first.id)
        expect(json['data']['order_number']).to eq(@orders.first.order_number)
        expect(json['data']['user_id']).to eq(@orders.first.user_id)
        expect(response).to have_http_status(:ok)
      end

      it "includes order_notes in the response" do
        expect(json['data']).to have_key('order_notes')
      end
    end

    context 'when the order does not exist' do
      before { get '/api/v1/orders/999999', headers: headers }

      it 'returns a not found error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/orders' do
    let(:valid_order_items_attributes) do
      Array.new(3) do
        {
          product_id: Faker::Number.number(digits: 5),
          quantity: 2,
          unit_price: 150,
          total_price: 300
        }
      end
    end

    let(:product_ids_and_quantities) do
      valid_order_items_attributes.map { |item| { product_id: item[:product_id], quantity: item[:quantity] } }
    end

    let(:valid_order_attributes) do
      {
        order_number: "ORD123456",
        status: "pending",
        shipping_address_line1: "123 Main St",
        shipping_address_line2: "Apt 4B",
        shipping_city: "New York",
        shipping_state: "NY",
        shipping_zip_code: "10001",
        shipping_country: "USA",
        recipient_name: "John Doe",
        recipient_phone: "+1234567890",
        order_notes: "Please deliver in the evening.",
        admin_notes: "Check the package carefully.",
        created_at: Time.current - 10.days,
        updated_at: Time.current - 2.days,
        total_price: 900
      }
    end

    let(:valid_payment_attributes) do
      {
        payment_method: %w[credit_card paypal bank_transfer].sample,
        payment_status: (status = %w[pending completed failed].sample),
        transaction_id: Faker::Alphanumeric.alphanumeric(number: 12).upcase,
        amount: Faker::Commerce.price(range: 50..1000),
        paid_at: (status == "completed" ? Faker::Time.backward(days: 2) : nil)
      }
    end

    context 'when the request is valid' do
      let(:url) { "#{ENV['PRODUCT_SERVICE_HOST']}/products/update_stock/batch" }

      before do
        stub_request(:patch, url)
          .with(
            body: product_ids_and_quantities.to_json,
            headers: headers
          )
          .to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a new order' do
        expect {
          post '/api/v1/orders', params: {
            order: valid_order_attributes,
            order_items: valid_order_items_attributes,
            payment: valid_payment_attributes
          }.to_json, headers: headers
        }.to change(Order, :count).by(1).and change(OrderItem, :count).by(3).and change(Payment, :count).by(1)

        expect(json['data']['order_number']).to eq('ORD123456')
        expect(response).to have_http_status(:created)
      end

      it 'sends a PATCH request to the product service to update stock' do
        post '/api/v1/orders', params: {
          order: valid_order_attributes,
          order_items: valid_order_items_attributes,
          payment: valid_payment_attributes
        }.to_json, headers: headers

        expect(WebMock).to have_requested(:patch, url)
                             .with(
                               body: product_ids_and_quantities.to_json,
                               headers: headers
                             ).once
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { order_number: '' }.to_json }

      it 'returns an error' do
        post '/api/v1/orders', params: invalid_attributes, headers: headers
        expect(json['error']).to include('Invalid record')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /api/v1/orders/:id' do
    let(:valid_attributes) { { status: 'completed' }.to_json }

    context 'when the order exists' do
      before { put "/api/v1/orders/#{@orders.first.id}", params: valid_attributes, headers: headers }

      it 'updates the order' do
        expect(json['data']['status']).to eq('completed')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when order is invalid' do
      before { put "/api/v1/orders/#{@orders.first.id}", params: { status: '' }.to_json, headers: headers }
      it 'raises an ActiveRecord::RecordInvalid error' do
        expect(json['error']).to include('Invalid record')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the order does not exist' do
      before { put '/api/v1/orders/999', params: valid_attributes, headers: headers }

      it 'returns an error' do
        expect(json['error']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
