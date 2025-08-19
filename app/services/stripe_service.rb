class StripeService
  def initialize
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  end

  # Tenant subscription methods
  def create_tenant_subscription(tenant, billing_tier)
    stripe_subscription = Stripe::Subscription.create(
      customer: tenant.stripe_customer_id,
      items: [{ price: billing_tier.stripe_price_id }],
      trial_period_days: billing_tier.trial? ? BillingConfiguration.current.trial_duration_days : nil,
      metadata: {
        tenant_id: tenant.id,
        billing_tier: billing_tier.name
      }
    )

    tenant.tenant_subscriptions.create!(
      billing_tier: billing_tier,
      status: stripe_subscription.status,
      stripe_subscription_id: stripe_subscription.id,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )
  end

  def update_tenant_subscription(subscription, billing_tier)
    stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    
    # Update the subscription item
    subscription_item = stripe_subscription.items.data.first
    Stripe::SubscriptionItem.update(
      subscription_item.id,
      price: billing_tier.stripe_price_id
    )

    # Update the subscription
    updated_subscription = Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      metadata: {
        tenant_id: subscription.tenant.id,
        billing_tier: billing_tier.name
      }
    )

    subscription.update!(
      billing_tier: billing_tier,
      status: updated_subscription.status,
      current_period_start: Time.at(updated_subscription.current_period_start),
      current_period_end: Time.at(updated_subscription.current_period_end)
    )
  end

  def cancel_tenant_subscription(subscription)
    return unless subscription.stripe_subscription_id

    stripe_subscription = Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      cancel_at_period_end: true
    )

    subscription.update!(status: stripe_subscription.status)
  end

  # User subscription methods (for Professional tier)
  def create_user_subscription(tenant_subscription, user, monthly_price)
    stripe_subscription = Stripe::Subscription.create(
      customer: user.stripe_customer_id,
      items: [{ price: get_user_price_id(monthly_price) }],
      metadata: {
        tenant_id: tenant_subscription.tenant.id,
        user_id: user.id,
        tenant_subscription_id: tenant_subscription.id
      }
    )

    tenant_subscription.user_subscriptions.create!(
      user: user,
      tenant: tenant_subscription.tenant,
      status: stripe_subscription.status,
      stripe_subscription_id: stripe_subscription.id,
      monthly_price: monthly_price
    )
  end

  def cancel_user_subscription(user_subscription)
    return unless user_subscription.stripe_subscription_id

    Stripe::Subscription.update(
      user_subscription.stripe_subscription_id,
      cancel_at_period_end: true
    )

    user_subscription.cancel!
  end

  # Stripe Connect methods
  def create_connect_account(tenant)
    account = Stripe::Account.create(
      type: 'express',
      country: 'US',
      email: tenant.admin_user.email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true }
      },
      metadata: {
        tenant_id: tenant.id
      }
    )

    tenant.create_stripe_connect_account!(
      account_id: account.id,
      status: account.status
    )

    account
  end

  def get_connect_account_link(connect_account)
    link = Stripe::AccountLink.create(
      account: connect_account.account_id,
      refresh_url: "#{Rails.application.config.frontend_url}/stripe/connect/refresh",
      return_url: "#{Rails.application.config.frontend_url}/stripe/connect/return",
      type: 'account_onboarding'
    )

    link.url
  end

  def update_connect_account_status(connect_account)
    account = Stripe::Account.retrieve(connect_account.account_id)
    connect_account.update_from_stripe!(account)
  end

  # Webhook handling
  def handle_webhook(event)
    case event.type
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_failed'
      handle_payment_failed(event.data.object)
    when 'invoice.payment_succeeded'
      handle_payment_succeeded(event.data.object)
    end
  end

  private

  def get_user_price_id(monthly_price)
    # This would need to be implemented based on your Stripe price setup
    # For now, we'll use a placeholder
    "price_user_#{monthly_price.to_i}"
  end

  def handle_subscription_updated(stripe_subscription)
    subscription = TenantSubscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    # Handle trial expiration
    if subscription.trial_expired? && BillingConfiguration.current.automatic_trial_conversion?
      handle_trial_expiration(subscription)
    end
  end

  def handle_subscription_deleted(stripe_subscription)
    subscription = TenantSubscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(status: 'canceled')
  end

  def handle_payment_failed(invoice)
    subscription = TenantSubscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'past_due')
  end

  def handle_payment_succeeded(invoice)
    subscription = TenantSubscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'active')
  end

  def handle_trial_expiration(subscription)
    # Send notification to tenant about trial expiration
    # This could trigger an email or in-app notification
    Rails.logger.info "Trial expired for tenant #{subscription.tenant.name}"
    
    # You might want to send an email here
    # TrialExpirationMailer.notify_tenant(subscription.tenant).deliver_later
  end
end
