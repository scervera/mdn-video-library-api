class Api::V1::PaymentIntentsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_stripe_connected
  before_action :set_payment_intent, only: [:show, :update, :confirm, :cancel]

  # GET /api/v1/payment_intents
  def index
    customer_id = params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    payment_intents = stripe_service.list_payment_intents(customer_id)
    
    render json: {
      customer_id: customer_id,
      payment_intents: payment_intents.data.map { |pi| format_payment_intent_response(pi) },
      has_more: payment_intents.has_more
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch payment intents: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/payment_intents/:id
  def show
    render json: { payment_intent: format_payment_intent_response(@payment_intent) }
  rescue Stripe::StripeError => e
    render json: { error: "Payment intent not found: #{e.message}" }, status: :not_found
  end

  # POST /api/v1/payment_intents
  def create
    customer_id = payment_intent_params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    payment_intent = stripe_service.create_payment_intent(
      amount: payment_intent_params[:amount],
      currency: payment_intent_params[:currency] || 'usd',
      customer: customer_id,
      payment_method: payment_intent_params[:payment_method],
      confirmation_method: payment_intent_params[:confirmation_method] || 'manual',
      confirm: payment_intent_params[:confirm] || false,
      description: payment_intent_params[:description],
      metadata: payment_intent_params[:metadata] || {}
    )

    render json: { 
      payment_intent: format_payment_intent_response(payment_intent),
      message: "Payment intent created successfully"
    }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create payment intent: #{e.message}" }, status: :unprocessable_entity
  end

  # PATCH /api/v1/payment_intents/:id
  def update
    updated_payment_intent = stripe_service.update_payment_intent(
      @payment_intent.id,
      payment_intent_update_params
    )

    render json: { 
      payment_intent: format_payment_intent_response(updated_payment_intent),
      message: "Payment intent updated successfully"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to update payment intent: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/payment_intents/:id/confirm
  def confirm
    confirmed_payment_intent = stripe_service.confirm_payment_intent(
      @payment_intent.id,
      payment_method: params[:payment_method],
      return_url: params[:return_url]
    )

    render json: { 
      payment_intent: format_payment_intent_response(confirmed_payment_intent),
      message: "Payment intent confirmed"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to confirm payment intent: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/payment_intents/:id/cancel
  def cancel
    cancelled_payment_intent = stripe_service.cancel_payment_intent(@payment_intent.id)

    render json: { 
      payment_intent: format_payment_intent_response(cancelled_payment_intent),
      message: "Payment intent cancelled"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to cancel payment intent: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/payment_intents/subscription_payment
  def subscription_payment
    subscription_id = params[:subscription_id]
    amount = params[:amount]
    
    unless subscription_id && amount
      return render json: { error: "Subscription ID and amount are required" }, status: :bad_request
    end

    # Find the subscription
    subscription = Current.tenant.tenant_subscriptions.find_by(id: subscription_id)
    unless subscription
      return render json: { error: "Subscription not found" }, status: :not_found
    end

    # Get the customer from the subscription
    customer_id = current_user.stripe_customer_id
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    payment_intent = stripe_service.create_payment_intent(
      amount: amount,
      currency: 'usd',
      customer: customer_id,
      confirmation_method: 'manual',
      confirm: false,
      description: "Payment for #{subscription.billing_tier.name} subscription",
      metadata: {
        subscription_id: subscription.id,
        tenant_id: Current.tenant.id,
        billing_tier: subscription.billing_tier.name
      }
    )

    render json: { 
      payment_intent: format_payment_intent_response(payment_intent),
      subscription: {
        id: subscription.id,
        billing_tier: subscription.billing_tier.name,
        status: subscription.status
      }
    }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create subscription payment: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_payment_intent
    @payment_intent = stripe_service.retrieve_payment_intent(params[:id])
  end

  def payment_intent_params
    params.permit(:amount, :currency, :customer_id, :payment_method, :confirmation_method, :confirm, :description, metadata: {})
  end

  def payment_intent_update_params
    params.permit(:amount, :currency, :payment_method, :description, metadata: {})
  end

  def format_payment_intent_response(payment_intent)
    {
      id: payment_intent.id,
      amount: payment_intent.amount,
      currency: payment_intent.currency,
      status: payment_intent.status,
      client_secret: payment_intent.client_secret,
      customer: payment_intent.customer,
      payment_method: payment_intent.payment_method,
      confirmation_method: payment_intent.confirmation_method,
      description: payment_intent.description,
      created: payment_intent.created,
      metadata: payment_intent.metadata&.to_h || {},
      next_action: payment_intent.next_action,
      last_payment_error: payment_intent.last_payment_error ? {
        type: payment_intent.last_payment_error.type,
        message: payment_intent.last_payment_error.message,
        code: payment_intent.last_payment_error.code
      } : nil
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
