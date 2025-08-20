class Api::V1::StripeCustomersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_admin_or_owner
  before_action :ensure_stripe_connected

  # GET /api/v1/stripe_customers
  def index
    customers = stripe_service.list_customers
    render json: {
      customers: customers.data.map { |customer| format_customer_response(customer) },
      has_more: customers.has_more
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch customers: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/stripe_customers/:id
  def show
    customer = stripe_service.retrieve_customer(params[:id])
    render json: { customer: format_customer_response(customer) }
  rescue Stripe::StripeError => e
    render json: { error: "Customer not found: #{e.message}" }, status: :not_found
  end

  # POST /api/v1/stripe_customers
  def create
    user = find_user_for_customer
    
    customer = stripe_service.create_customer(
      email: user.email,
      name: user.full_name,
      metadata: {
        user_id: user.id,
        tenant_id: Current.tenant.id
      }
    )

    # Update user with Stripe customer ID
    user.update!(stripe_customer_id: customer.id)

    render json: { 
      customer: format_customer_response(customer),
      message: "Customer created successfully"
    }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create customer: #{e.message}" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "User not found" }, status: :not_found
  end

  # PATCH /api/v1/stripe_customers/:id
  def update
    customer = stripe_service.update_customer(
      params[:id],
      customer_update_params
    )

    render json: { 
      customer: format_customer_response(customer),
      message: "Customer updated successfully"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to update customer: #{e.message}" }, status: :unprocessable_entity
  end

  # DELETE /api/v1/stripe_customers/:id
  def destroy
    stripe_service.delete_customer(params[:id])
    
    # Remove Stripe customer ID from user
    user = Current.tenant.users.find_by(stripe_customer_id: params[:id])
    user&.update!(stripe_customer_id: nil)

    render json: { message: "Customer deleted successfully" }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to delete customer: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/stripe_customers/:id/payment_methods
  def payment_methods
    customer = stripe_service.retrieve_customer(params[:id])
    payment_methods = stripe_service.list_customer_payment_methods(params[:id])
    
    render json: {
      customer_id: customer.id,
      payment_methods: payment_methods.data.map { |pm| format_payment_method_response(pm) }
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch payment methods: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/stripe_customers/:id/subscriptions
  def subscriptions
    customer = stripe_service.retrieve_customer(params[:id])
    subscriptions = stripe_service.list_customer_subscriptions(params[:id])
    
    render json: {
      customer_id: customer.id,
      subscriptions: subscriptions.data.map { |sub| format_subscription_response(sub) }
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch subscriptions: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def find_user_for_customer
    user_id = params[:user_id] || current_user.id
    Current.tenant.users.find(user_id)
  end

  def customer_update_params
    params.permit(:name, :email, :phone, :description, metadata: {})
  end

  def format_customer_response(customer)
    {
      id: customer.id,
      email: customer.email,
      name: customer.name,
      phone: customer.phone,
      description: customer.description,
      created: customer.created,
      default_payment_method: customer.invoice_settings&.default_payment_method,
      metadata: customer.metadata&.to_h || {},
      balance: customer.balance,
      currency: customer.currency
    }
  end

  def format_payment_method_response(payment_method)
    {
      id: payment_method.id,
      type: payment_method.type,
      card: payment_method.card ? {
        brand: payment_method.card.brand,
        last4: payment_method.card.last4,
        exp_month: payment_method.card.exp_month,
        exp_year: payment_method.card.exp_year
      } : nil,
      created: payment_method.created
    }
  end

  def format_subscription_response(subscription)
    {
      id: subscription.id,
      status: subscription.status,
      current_period_start: subscription.current_period_start,
      current_period_end: subscription.current_period_end,
      cancel_at_period_end: subscription.cancel_at_period_end,
      created: subscription.created
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

  def ensure_admin_or_owner
    unless current_user.admin? || current_user.owner?
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end
