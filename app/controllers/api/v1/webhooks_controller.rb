class Api::V1::WebhooksController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # POST /api/v1/webhooks/stripe
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid payload: #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Invalid signature: #{e.message}"
      return head :bad_request
    end

    # Handle the event
    handle_stripe_webhook(event)

    head :ok
  rescue => e
    Rails.logger.error "Webhook error: #{e.message}"
    head :internal_server_error
  end

  private

  def handle_stripe_webhook(event)
    case event.type
    when 'account.updated'
      handle_account_updated(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_failed'
      handle_payment_failed(event.data.object)
    when 'invoice.payment_succeeded'
      handle_payment_succeeded(event.data.object)
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_intent_failed(event.data.object)
    when 'setup_intent.succeeded'
      handle_setup_intent_succeeded(event.data.object)
    when 'setup_intent.setup_failed'
      handle_setup_intent_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end
  end

  def handle_account_updated(stripe_account)
    # Find the connect account and update it
    connect_account = StripeConnectAccount.find_by(account_id: stripe_account.id)
    return unless connect_account

    connect_account.update_from_stripe!(stripe_account)
    
    Rails.logger.info "Updated Stripe Connect account: #{stripe_account.id}"
  end

  def handle_subscription_updated(stripe_subscription)
    # Handle subscription updates
    subscription = TenantSubscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.items.data.first.current_period_start),
      current_period_end: Time.at(stripe_subscription.items.data.first.current_period_end)
    )

    Rails.logger.info "Updated subscription: #{stripe_subscription.id}"
  end

  def handle_subscription_deleted(stripe_subscription)
    # Handle subscription deletions
    subscription = TenantSubscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(status: 'canceled')
    
    Rails.logger.info "Canceled subscription: #{stripe_subscription.id}"
  end

  def handle_payment_failed(invoice)
    # Handle failed payments
    subscription = TenantSubscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'past_due')
    
    # Send notification to tenant about failed payment
    Rails.logger.info "Payment failed for subscription: #{invoice.subscription}"
  end

  def handle_payment_succeeded(invoice)
    # Handle successful payments
    subscription = TenantSubscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'active')
    
    Rails.logger.info "Payment succeeded for subscription: #{invoice.subscription}"
  end

  def handle_payment_intent_succeeded(payment_intent)
    # Handle successful payment intents
    Rails.logger.info "Payment intent succeeded: #{payment_intent.id}"
    
    # You might want to update order status or send confirmation emails here
  end

  def handle_payment_intent_failed(payment_intent)
    # Handle failed payment intents
    Rails.logger.info "Payment intent failed: #{payment_intent.id}"
    
    # You might want to send failure notifications here
  end

  def handle_setup_intent_succeeded(setup_intent)
    # Handle successful setup intents (payment method added)
    Rails.logger.info "Setup intent succeeded: #{setup_intent.id}"
    
    # You might want to update UI or send confirmation here
  end

  def handle_setup_intent_failed(setup_intent)
    # Handle failed setup intents
    Rails.logger.info "Setup intent failed: #{setup_intent.id}"
    
    # You might want to show error messages to user
  end
end
