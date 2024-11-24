class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update]

  # GET /api/v1/orders
  def index
    authorize! :read, Order
    pagy, orders = pagy(Order.accessible_by(current_ability).order(updated_at: :desc), limit: params[:per_page] || 10)
    render json: {
      data: ActiveModelSerializers::SerializableResource.new(orders,
                                                             each_serializer: OrderCollectionSerializer).as_json,
      meta: pagy_metadata(pagy)
    }, status: :ok
  end

  # GET /api/v1/orders/:id
  def show
    authorize! :read, @order
    render json: { data: ActiveModelSerializers::SerializableResource.new(@order).as_json }, status: :ok
  end

  # POST /api/v1/orders
  def create
    authorize! :create, Order
    order = Order.new(order_params.merge({ user_id: @current_user_id }))
    raise ActiveRecord::RecordInvalid unless order.save

    products = []
    ActiveRecord::Base.transaction do
      order_items_params.each do |order_item|
        order.order_items.create!(order_item)
        products << {
          product_id: order_item[:product_id],
          quantity: order_item[:quantity]
        }
      end

      order.create_payment!(payment_params)
    end
    update_stock(products)

    render json: { message: 'Order created successfully',
                   data: ActiveModelSerializers::SerializableResource.new(order).as_json }, status: :created
  end

  # PATCH/PUT /api/v1/orders/:id
  def update
    authorize! :update, @order
    raise ActiveRecord::RecordInvalid unless @order.update(order_params)

    render json: { message: 'Order updated successfully',
                   data: ActiveModelSerializers::SerializableResource.new(@order).as_json }, status: :ok
  end

  private

  # Todo: Use Event-Driven Architecture (message queue such as RabbitMQ, Kafka, Redis or Amazon SNS & Amazon SQS) in practice
  def update_stock(products)
    uri = URI("#{ENV['PRODUCT_SERVICE_HOST']}/products/update_stock/batch")
    request = Net::HTTP::Patch.new(uri, { "Content-Type" => "application/json", "Authorization" => "Bearer #{@token}" })
    request.body = products.to_json
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
  end

  def set_order
    @order = Order.accessible_by(current_ability).find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :order_number, :status, :shipping_address_line1, :shipping_address_line2,
      :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country,
      :recipient_name, :recipient_phone, :order_notes, :total_price
    )
  end

  def order_items_params
    params.require(:order_items).map do |item|
      item.permit(:product_id, :quantity, :unit_price, :total_price)
    end
  end

  def payment_params
    params.require(:payment).permit(
      :payment_method, :payment_status, :transaction_id, :amount, :paid_at
    )
  end
end
