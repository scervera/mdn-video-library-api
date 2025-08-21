class Api::V1::SubscriptionsController < Api::V1::BaseController
  before_action :ensure_admin_user
  before_action :set_subscription, only: [:show, :update, :cancel]

  # GET /api/v1/subscriptions
  def index
    subscriptions = Current.tenant.tenant_subscriptions.includes(:billing_tier)
    
    render json: {
      subscriptions: subscriptions.map do |subscription|
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
      end,
      current_subscription: Current.tenant.current_subscription&.id
    }
  end

  # GET /api/v1/subscriptions/:id
  def show
    render json: {
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
      render json: { 
        error: "Invalid billing tier: '#{received_tier}'. Available tiers: #{available_tiers}",
        received_tier: received_tier,
        available_tiers: available_tiers
      }, status: :bad_request
      return
    end

    # Check if tenant already has an active subscription
    if Current.tenant.current_subscription.present?
      render json: { error: 'Tenant already has an active subscription' }, status: :unprocessable_entity
      return
    end

    # Create billing tier if it doesn't exist
    billing_tier = Current.tenant.billing_tiers.find_or_create_by(name: tier_data['name']) do |tier|
      tier.monthly_price = tier_data['monthly_price']
      tier.per_user_price = tier_data['per_user_price']
      tier.user_limit = tier_data['user_limit']
      tier.features = tier_data['features']
    end

    # Create subscription
    subscription = Current.tenant.tenant_subscriptions.build(
      billing_tier: billing_tier,
      status: 'trial'
    )

    if subscription.save
      render json: {
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
        days_until_trial_expires: subscription.days_until_trial_expires
      }, status: :created
    else
      render json: { error: subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/subscriptions/:id
  def update
    config = BillingConfiguration.current
    tier_data = config.get_tier(subscription_params[:billing_tier_id])

    if tier_data.nil?
      render json: { error: 'Invalid billing tier' }, status: :bad_request
      return
    end

    # Create or find billing tier
    billing_tier = Current.tenant.billing_tiers.find_or_create_by(name: tier_data['name']) do |tier|
      tier.monthly_price = tier_data['monthly_price']
      tier.per_user_price = tier_data['per_user_price']
      tier.user_limit = tier_data['user_limit']
      tier.features = tier_data['features']
    end

    @subscription.billing_tier = billing_tier

    if @subscription.save
      render json: {
        id: @subscription.id,
        status: @subscription.status,
        billing_tier: {
          id: billing_tier.name,
          name: billing_tier.name,
          monthly_price: billing_tier.monthly_price,
          per_user_price: billing_tier.per_user_price,
          user_limit: billing_tier.user_limit
        },
        trial_ends_at: @subscription.trial_ends_at,
        days_until_trial_expires: @subscription.days_until_trial_expires
      }
    else
      render json: { error: @subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/subscriptions/:id
  def cancel
    if @subscription.update(status: 'canceled')
      render json: { message: 'Subscription canceled successfully' }
    else
      render json: { error: @subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def set_subscription
    @subscription = Current.tenant.tenant_subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Subscription not found' }, status: :not_found
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
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end
end
