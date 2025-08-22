class Api::V1::SubscriptionsController < Api::V1::BaseController
  before_action :ensure_admin_user
  before_action :set_subscription, only: [:show, :update, :cancel]

  # GET /api/v1/subscriptions
  def index
    subscriptions = Current.tenant.tenant_subscriptions.includes(:billing_tier)
    
    subscription_data = subscriptions.map do |subscription|
      {
        id: subscription.id,
        status: subscription.status,
        billing_tier: {
          id: subscription.billing_tier.name,
          name: subscription.billing_tier.name,
          monthly_price: subscription.billing_tier.monthly_price,
          per_user_price: subscription.billing_tier.per_user_price,
          user_limit: subscription.billing_tier.user_limit
        },
        trial_ends_at: subscription.trial_ends_at,
        current_period_start: subscription.current_period_start,
        current_period_end: subscription.current_period_end,
        current_user_count: subscription.current_user_count,
        can_add_user: subscription.can_add_user?,
        days_until_trial_expires: subscription.days_until_trial_expires
      }
    end

    meta = {
      current_subscription: Current.tenant.current_subscription&.id
    }

    render_list_response(subscription_data, meta: meta)
  end

  # GET /api/v1/subscriptions/:id
  def show
    subscription_data = {
      id: @subscription.id,
      status: @subscription.status,
      billing_tier: {
        id: @subscription.billing_tier.name,
        name: @subscription.billing_tier.name,
        monthly_price: @subscription.billing_tier.monthly_price,
        per_user_price: @subscription.billing_tier.per_user_price,
        user_limit: @subscription.billing_tier.user_limit
      },
      trial_ends_at: @subscription.trial_ends_at,
      current_period_start: @subscription.current_period_start,
      current_period_end: @subscription.current_period_end,
      current_user_count: @subscription.current_user_count,
      can_add_user: @subscription.can_add_user?,
      days_until_trial_expires: @subscription.days_until_trial_expires,
      user_subscriptions: @subscription.user_subscriptions.map do |user_sub|
        {
          id: user_sub.id,
          user: {
            id: user_sub.user.id,
            email: user_sub.user.email,
            full_name: user_sub.user.full_name
          },
          status: user_sub.status,
          monthly_price: user_sub.monthly_price
        }
      end
    }

    render_single_response(subscription_data)
  end

  # POST /api/v1/subscriptions
  def create
    # Debug logging
    Rails.logger.info "Subscription create params: #{params.inspect}"
    Rails.logger.info "Billing tier ID: #{subscription_params[:billing_tier_id]}"
    
    config = BillingConfiguration.current
    tier_data = config.get_tier(subscription_params[:billing_tier_id])

    if tier_data.nil?
      available_tiers = config.tier_names.join(', ')
      received_tier = subscription_params[:billing_tier_id]
      render_error_response(
        error_code: 'invalid_billing_tier',
        message: "Invalid billing tier: '#{received_tier}'. Available tiers: #{available_tiers}",
        details: {
          received_tier: received_tier,
          available_tiers: available_tiers
        },
        status: :bad_request
      )
      return
    end

    # Check if tenant already has an active subscription
    if Current.tenant.current_subscription.present?
      render_error_response(
        error_code: 'subscription_exists',
        message: 'Tenant already has an active subscription',
        status: :unprocessable_entity
      )
      return
    end

    # Create billing tier if it doesn't exist
    billing_tier = Current.tenant.billing_tiers.find_or_create_by(name: tier_data['name']) do |tier|
      tier.monthly_price = tier_data['monthly_price']
      tier.per_user_price = tier_data['per_user_price']
      tier.user_limit = tier_data['user_limit']
      tier.features = tier_data['features']
    end

    begin
      # Create subscription with Stripe integration
      stripe_service = StripeService.new(Current.tenant)
      subscription = stripe_service.create_tenant_subscription_with_stripe(Current.tenant, billing_tier)

      subscription_data = {
        id: subscription.id,
        status: subscription.status,
        billing_tier: {
          id: billing_tier.name,
          name: billing_tier.name,
          monthly_price: billing_tier.monthly_price,
          per_user_price: billing_tier.per_user_price,
          user_limit: billing_tier.user_limit
        },
        trial_ends_at: subscription.trial_ends_at,
        days_until_trial_expires: subscription.days_until_trial_expires,
        stripe_subscription_id: subscription.stripe_subscription_id
      }
      
      render_single_response(subscription_data, status: :created)
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error creating subscription: #{e.message}"
      render_error_response(
        error_code: 'stripe_error',
        message: 'Payment processing failed',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    rescue => e
      Rails.logger.error "Error creating subscription: #{e.message}"
      render_error_response(
        error_code: 'subscription_creation_failed',
        message: 'Failed to create subscription',
        details: { error: e.message },
        status: :internal_server_error
      )
    end
  end

  # PUT /api/v1/subscriptions/:id
  def update
    config = BillingConfiguration.current
    tier_data = config.get_tier(subscription_params[:billing_tier_id])

    if tier_data.nil?
      render_error_response(
        error_code: 'invalid_billing_tier',
        message: 'Invalid billing tier',
        status: :bad_request
      )
      return
    end

    # Create or find billing tier
    billing_tier = Current.tenant.billing_tiers.find_or_create_by(name: tier_data['name']) do |tier|
      tier.monthly_price = tier_data['monthly_price']
      tier.per_user_price = tier_data['per_user_price']
      tier.user_limit = tier_data['user_limit']
      tier.features = tier_data['features']
    end

    begin
      stripe_service = StripeService.new(Current.tenant)
      
      # Handle trial subscription conversion
      if @subscription.trial? && @subscription.stripe_subscription_id.blank?
        # First, ensure tenant has a Stripe customer
        customer_id = stripe_service.ensure_tenant_customer(Current.tenant)
        
        # Then, attach payment method to customer if provided
        if subscription_params[:payment_method_id].present?
          begin
            stripe_service.add_payment_method_to_customer(
              customer_id,
              subscription_params[:payment_method_id]
            )
          rescue Stripe::StripeError => e
            Rails.logger.error "Failed to attach payment method: #{e.message}"
            render_error_response(
              error_code: 'payment_method_attachment_failed',
              message: 'Failed to attach payment method',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
            return
          end
        end
        
        # Convert trial to paid subscription
        subscription = stripe_service.create_tenant_subscription_with_stripe(Current.tenant, billing_tier)
        
        subscription_data = {
          id: subscription.id,
          status: subscription.status,
          billing_tier: {
            id: billing_tier.name,
            name: billing_tier.name,
            monthly_price: billing_tier.monthly_price,
            per_user_price: billing_tier.per_user_price,
            user_limit: billing_tier.user_limit
          },
          trial_ends_at: subscription.trial_ends_at,
          days_until_trial_expires: subscription.days_until_trial_expires,
          stripe_subscription_id: subscription.stripe_subscription_id
        }
      else
        # Update existing paid subscription with proration
        result = stripe_service.update_tenant_subscription_with_proration(@subscription, billing_tier)
        
        subscription = result[:subscription]
        proration_data = result[:proration]

              subscription_data = {
          id: subscription.id,
          status: subscription.status,
          billing_tier: {
            id: billing_tier.name,
            name: billing_tier.name,
            monthly_price: billing_tier.monthly_price,
            per_user_price: billing_tier.per_user_price,
            user_limit: billing_tier.user_limit
          },
          trial_ends_at: subscription.trial_ends_at,
          days_until_trial_expires: subscription.days_until_trial_expires,
          proration: {
            amount: proration_data[:amount],
            credit: proration_data[:credit],
            charge: proration_data[:charge],
            remaining_days: proration_data[:remaining_days]
          }
        }
      end
      
      render_single_response(subscription_data)
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error updating subscription: #{e.message}"
      render_error_response(
        error_code: 'stripe_error',
        message: 'Payment processing failed',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    rescue => e
      Rails.logger.error "Error updating subscription: #{e.message}"
      render_error_response(
        error_code: 'subscription_update_failed',
        message: 'Failed to update subscription',
        details: { error: e.message },
        status: :internal_server_error
      )
    end
  end

  # DELETE /api/v1/subscriptions/:id
  def cancel
    begin
      stripe_service = StripeService.new(Current.tenant)
      stripe_service.cancel_tenant_subscription(@subscription)
      
      render_action_response(message: 'Subscription canceled successfully')
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error canceling subscription: #{e.message}"
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to cancel subscription',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    rescue => e
      Rails.logger.error "Error canceling subscription: #{e.message}"
      render_error_response(
        error_code: 'subscription_cancel_failed',
        message: 'Failed to cancel subscription',
        details: { error: e.message },
        status: :internal_server_error
      )
    end
  end

  private

  def set_subscription
    @subscription = Current.tenant.tenant_subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found_error('Subscription')
  end

  def subscription_params
    # Handle both nested and direct parameters
    if params[:subscription]
      params.require(:subscription).permit(:billing_tier_id)
    else
      # Allow direct parameters for flexibility
      ActionController::Parameters.new(
        billing_tier_id: params[:billing_tier_id] || params[:tier_id] || params[:tierId]
      )
    end
  end

  def ensure_admin_user
    unless current_user&.admin?
      render_forbidden_error('Admin access required')
    end
  end
end
