class Api::V1::PaymentMethodsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_stripe_connected
  before_action :set_customer, only: [:index, :create, :set_default]
  before_action :set_payment_method, only: [:show, :update, :destroy]

  # GET /api/v1/payment_methods
  # GET /api/v1/payment_methods?customer_id=cus_xxx
  def index
    if @customer
      payment_methods = stripe_service.list_customer_payment_methods(@customer.id)
      render json: {
        customer_id: @customer.id,
        payment_methods: payment_methods.data.map { |pm| format_payment_method_response(pm) }
      }
    else
      # List current user's payment methods
      unless current_user.stripe_customer_id
        return render json: { error: "User has no Stripe customer account" }, status: :not_found
      end
      
      payment_methods = stripe_service.list_customer_payment_methods(current_user.stripe_customer_id)
      render json: {
        customer_id: current_user.stripe_customer_id,
        payment_methods: payment_methods.data.map { |pm| format_payment_method_response(pm) }
      }
    end
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch payment methods: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/payment_methods/:id
  def show
    render json: { payment_method: format_payment_method_response(@payment_method) }
  rescue Stripe::StripeError => e
    render json: { error: "Payment method not found: #{e.message}" }, status: :not_found
  end

  # POST /api/v1/payment_methods
  def create
    customer_id = @customer&.id || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    # Create payment method from payment method token/source
    payment_method = stripe_service.create_payment_method(
      type: payment_method_params[:type] || 'card',
      card: payment_method_params[:card],
      customer: customer_id
    )

    # Attach to customer if not already attached
    stripe_service.attach_payment_method_to_customer(payment_method.id, customer_id)

    # Set as default if requested
    if payment_method_params[:set_as_default]
      stripe_service.set_default_payment_method(customer_id, payment_method.id)
    end

    render json: { 
      payment_method: format_payment_method_response(payment_method),
      message: "Payment method added successfully"
    }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create payment method: #{e.message}" }, status: :unprocessable_entity
  end

  # PATCH /api/v1/payment_methods/:id
  def update
    updated_payment_method = stripe_service.update_payment_method(
      @payment_method.id,
      payment_method_update_params
    )

    render json: { 
      payment_method: format_payment_method_response(updated_payment_method),
      message: "Payment method updated successfully"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to update payment method: #{e.message}" }, status: :unprocessable_entity
  end

  # DELETE /api/v1/payment_methods/:id
  def destroy
    stripe_service.detach_payment_method(@payment_method.id)

    render json: { message: "Payment method removed successfully" }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to remove payment method: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/payment_methods/:id/set_default
  def set_default
    customer_id = @customer&.id || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    stripe_service.set_default_payment_method(customer_id, params[:id])

    render json: { message: "Default payment method updated successfully" }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to set default payment method: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/payment_methods/setup_intent
  def setup_intent
    customer_id = params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    setup_intent = stripe_service.create_setup_intent(customer_id)

    render json: {
      client_secret: setup_intent.client_secret,
      setup_intent_id: setup_intent.id
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create setup intent: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_customer
    if params[:customer_id] && (current_user.admin? || current_user.owner?)
      @customer = stripe_service.retrieve_customer(params[:customer_id])
    else
      @customer = nil
    end
  end

  def set_payment_method
    @payment_method = stripe_service.retrieve_payment_method(params[:id])
  end

  def payment_method_params
    params.permit(:type, :set_as_default, card: {})
  end

  def payment_method_update_params
    params.permit(card: [:exp_month, :exp_year], billing_details: [:name, :email, :phone, address: [:line1, :line2, :city, :state, :postal_code, :country]])
  end

  def format_payment_method_response(payment_method)
    {
      id: payment_method.id,
      type: payment_method.type,
      card: payment_method.card ? {
        brand: payment_method.card.brand,
        last4: payment_method.card.last4,
        exp_month: payment_method.card.exp_month,
        exp_year: payment_method.card.exp_year,
        fingerprint: payment_method.card.fingerprint
      } : nil,
      billing_details: payment_method.billing_details ? {
        name: payment_method.billing_details.name,
        email: payment_method.billing_details.email,
        phone: payment_method.billing_details.phone,
        address: payment_method.billing_details.address&.to_h
      } : nil,
      created: payment_method.created,
      customer: payment_method.customer
    }
  end

  def stripe_service
    @stripe_service ||= StripeService.new(Current.tenant)
  end

  def ensure_stripe_connected
    unless Current.tenant.stripe_connect_account&.charges_enabled?
      render json: { 
        error: "Stripe account not connected or not enabled for charges" 
      }, status: :unprocessable_entity
    end
  end
end
