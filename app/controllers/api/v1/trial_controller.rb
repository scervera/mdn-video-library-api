class Api::V1::TrialController < Api::V1::BaseController
  before_action :ensure_admin_user

  # GET /api/v1/trial/status
  def status
    subscription = Current.tenant.current_subscription

    if subscription.nil?
      render json: {
        has_subscription: false,
        trial_active: false,
        message: 'No subscription found'
      }
      return
    end

    render json: {
      has_subscription: true,
      trial_active: subscription.trial?,
      trial_expired: subscription.trial_expired?,
      status: subscription.status,
      trial_ends_at: subscription.trial_ends_at,
      days_until_trial_expires: subscription.days_until_trial_expires,
      current_user_count: subscription.current_user_count,
      user_limit: subscription.billing_tier.user_limit,
      can_add_user: subscription.can_add_user?,
      billing_tier: {
        name: subscription.billing_tier.name,
        monthly_price: subscription.billing_tier.monthly_price,
        per_user_price: subscription.billing_tier.per_user_price
      }
    }
  end

  # POST /api/v1/trial/start
  def start
    # Check if tenant already has a subscription
    if Current.tenant.current_subscription.present?
      render json: { error: 'Tenant already has a subscription' }, status: :unprocessable_entity
      return
    end

    config = BillingConfiguration.current
    trial_tier_data = config.trial_tier

    if trial_tier_data.nil?
      render json: { error: 'Trial tier not configured' }, status: :internal_server_error
      return
    end

    # Create trial billing tier
    billing_tier = Current.tenant.billing_tiers.find_or_create_by(name: trial_tier_data['name']) do |tier|
      tier.monthly_price = trial_tier_data['monthly_price']
      tier.per_user_price = trial_tier_data['per_user_price']
      tier.user_limit = trial_tier_data['user_limit']
      tier.features = trial_tier_data['features']
    end

    # Create trial subscription
    subscription = Current.tenant.tenant_subscriptions.build(
      billing_tier: billing_tier,
      status: 'trial'
    )

    if subscription.save
      render json: {
        id: subscription.id,
        status: subscription.status,
        trial_ends_at: subscription.trial_ends_at,
        days_until_trial_expires: subscription.days_until_trial_expires,
        user_limit: billing_tier.user_limit,
        message: "Trial started successfully. You have #{subscription.days_until_trial_expires} days remaining."
      }, status: :created
    else
      render json: { error: subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/trial/convert
  def convert
    subscription = Current.tenant.current_subscription

    if subscription.nil?
      render json: { error: 'No subscription found' }, status: :not_found
      return
    end

    unless subscription.trial?
      render json: { error: 'Subscription is not in trial' }, status: :unprocessable_entity
      return
    end

    # Convert trial to active
    if subscription.update(status: 'active')
      render json: {
        id: subscription.id,
        status: subscription.status,
        message: 'Trial converted to active subscription successfully'
      }
    else
      render json: { error: subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/trial/expired
  def expired
    expired_trials = TenantSubscription.expired_trials.includes(:tenant, :billing_tier)
    
    render json: {
      expired_trials: expired_trials.map do |subscription|
        {
          id: subscription.id,
          tenant: {
            id: subscription.tenant.id,
            name: subscription.tenant.name,
            slug: subscription.tenant.slug
          },
          trial_ends_at: subscription.trial_ends_at,
          days_expired: ((Time.current - subscription.trial_ends_at) / 1.day).to_i,
          current_user_count: subscription.current_user_count,
          user_limit: subscription.billing_tier.user_limit
        }
      end
    }
  end

  private

  def ensure_admin_user
    unless current_user&.admin?
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end
end
