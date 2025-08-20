class StripeService
  def initialize(tenant = nil)
    @tenant = tenant
    # Use tenant's Stripe Connect account if available, otherwise fall back to platform account
    if tenant&.stripe_connect_account&.charges_enabled?
      Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
      @stripe_account = tenant.stripe_connect_account.account_id
    else
      Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
      @stripe_account = nil
    end
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

  def retrieve_connect_account(account_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Account.retrieve(account_id, params)
  end

  def delete_connect_account(account_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    account = Stripe::Account.retrieve(account_id, params)
    account.delete
  end

  # Customer management methods
  def list_customers(limit: 10, starting_after: nil)
    params = { limit: limit }
    params[:starting_after] = starting_after if starting_after
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Customer.list(params)
  end

  def retrieve_customer(customer_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Customer.retrieve(customer_id, params)
  end

  def create_customer(email:, name: nil, metadata: {})
    params = {
      email: email,
      name: name,
      metadata: metadata
    }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Customer.create(params)
  end

  def update_customer(customer_id, updates)
    params = updates.dup
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Customer.update(customer_id, params)
  end

  def delete_customer(customer_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    customer = Stripe::Customer.retrieve(customer_id, params)
    customer.delete
  end

  def list_customer_payment_methods(customer_id, type: 'card')
    params = {
      customer: customer_id,
      type: type
    }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentMethod.list(params)
  end

  def list_customer_subscriptions(customer_id)
    params = {
      customer: customer_id
    }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Subscription.list(params)
  end

  # Payment method management
  def create_payment_method(type:, card: nil, customer: nil)
    params = { type: type }
    params[:card] = card if card
    params[:customer] = customer if customer
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentMethod.create(params)
  end

  def retrieve_payment_method(payment_method_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentMethod.retrieve(payment_method_id, params)
  end

  def update_payment_method(payment_method_id, updates)
    params = updates.dup
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentMethod.update(payment_method_id, params)
  end

  def attach_payment_method_to_customer(payment_method_id, customer_id)
    params = { customer: customer_id }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    payment_method = Stripe::PaymentMethod.retrieve(payment_method_id, { stripe_account: @stripe_account }.compact)
    payment_method.attach(params)
  end

  def detach_payment_method(payment_method_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    payment_method = Stripe::PaymentMethod.retrieve(payment_method_id, { stripe_account: @stripe_account }.compact)
    payment_method.detach
  end

  def set_default_payment_method(customer_id, payment_method_id)
    params = {
      invoice_settings: {
        default_payment_method: payment_method_id
      }
    }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Customer.update(customer_id, params)
  end

  def create_setup_intent(customer_id, payment_method_types: ['card'])
    params = {
      customer: customer_id,
      payment_method_types: payment_method_types,
      usage: 'off_session'
    }
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::SetupIntent.create(params)
  end

  # Payment intent management
  def list_payment_intents(customer_id, limit: 10, starting_after: nil)
    params = {
      customer: customer_id,
      limit: limit
    }
    params[:starting_after] = starting_after if starting_after
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentIntent.list(params)
  end

  def retrieve_payment_intent(payment_intent_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentIntent.retrieve(payment_intent_id, params)
  end

  def create_payment_intent(amount:, currency: 'usd', customer: nil, payment_method: nil, confirmation_method: 'manual', confirm: false, description: nil, metadata: {})
    params = {
      amount: amount,
      currency: currency,
      confirmation_method: confirmation_method,
      confirm: confirm
    }
    params[:customer] = customer if customer
    params[:payment_method] = payment_method if payment_method
    params[:description] = description if description
    params[:metadata] = metadata if metadata.any?
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentIntent.create(params)
  end

  def update_payment_intent(payment_intent_id, updates)
    params = updates.dup
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::PaymentIntent.update(payment_intent_id, params)
  end

  def confirm_payment_intent(payment_intent_id, payment_method: nil, return_url: nil)
    params = {}
    params[:payment_method] = payment_method if payment_method
    params[:return_url] = return_url if return_url
    params[:stripe_account] = @stripe_account if @stripe_account
    
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id, { stripe_account: @stripe_account }.compact)
    payment_intent.confirm(params)
  end

  def cancel_payment_intent(payment_intent_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id, { stripe_account: @stripe_account }.compact)
    payment_intent.cancel
  end

  # Invoice management
  def list_invoices(customer: nil, limit: 10, starting_after: nil)
    params = { limit: limit }
    params[:customer] = customer if customer
    params[:starting_after] = starting_after if starting_after
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Invoice.list(params)
  end

  def retrieve_invoice(invoice_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Invoice.retrieve(invoice_id, params)
  end

  def create_invoice(customer:, description: nil, metadata: {}, auto_advance: true, collection_method: 'charge_automatically')
    params = {
      customer: customer,
      auto_advance: auto_advance,
      collection_method: collection_method
    }
    params[:description] = description if description
    params[:metadata] = metadata if metadata.any?
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Invoice.create(params)
  end

  def create_invoice_item(customer:, invoice: nil, amount:, currency: 'usd', description: nil)
    params = {
      customer: customer,
      amount: amount,
      currency: currency
    }
    params[:invoice] = invoice if invoice
    params[:description] = description if description
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::InvoiceItem.create(params)
  end

  def pay_invoice(invoice_id, payment_method: nil, source: nil)
    params = {}
    params[:payment_method] = payment_method if payment_method
    params[:source] = source if source
    params[:stripe_account] = @stripe_account if @stripe_account
    
    invoice = Stripe::Invoice.retrieve(invoice_id, { stripe_account: @stripe_account }.compact)
    invoice.pay(params)
  end

  def void_invoice(invoice_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    invoice = Stripe::Invoice.retrieve(invoice_id, { stripe_account: @stripe_account }.compact)
    invoice.void_invoice
  end

  def mark_invoice_uncollectible(invoice_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    invoice = Stripe::Invoice.retrieve(invoice_id, { stripe_account: @stripe_account }.compact)
    invoice.mark_uncollectible
  end

  def send_invoice(invoice_id)
    params = {}
    params[:stripe_account] = @stripe_account if @stripe_account
    
    invoice = Stripe::Invoice.retrieve(invoice_id, { stripe_account: @stripe_account }.compact)
    invoice.send_invoice
  end

  def retrieve_upcoming_invoice(customer:, subscription: nil)
    params = { customer: customer }
    params[:subscription] = subscription if subscription
    params[:stripe_account] = @stripe_account if @stripe_account
    
    Stripe::Invoice.upcoming(params)
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
