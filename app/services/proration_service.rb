class ProrationService
  def initialize(subscription)
    @subscription = subscription
    @tenant = subscription.tenant
  end

  # Calculate proration for subscription tier changes
  def calculate_proration(new_billing_tier)
    return { amount: 0, credit: 0, charge: 0 } unless @subscription.stripe_subscription_id

    old_tier = @subscription.billing_tier
    new_tier = new_billing_tier

    # Calculate daily rates
    old_daily_rate = calculate_daily_rate(old_tier)
    new_daily_rate = calculate_daily_rate(new_tier)

    # Calculate remaining days in current billing period
    remaining_days = calculate_remaining_days

    # Calculate proration amounts
    unused_credit = old_daily_rate * remaining_days
    new_charge = new_daily_rate * remaining_days

    # Determine if this is a credit or charge
    if unused_credit > new_charge
      # Downgrade or same price - customer gets credit
      credit_amount = (unused_credit - new_charge) * 100 # Convert to cents
      charge_amount = 0
    else
      # Upgrade - customer pays the difference
      credit_amount = 0
      charge_amount = (new_charge - unused_credit) * 100 # Convert to cents
    end

    {
      amount: charge_amount,
      credit: credit_amount,
      charge: charge_amount,
      remaining_days: remaining_days,
      old_daily_rate: old_daily_rate,
      new_daily_rate: new_daily_rate,
      unused_credit: unused_credit,
      new_charge: new_charge
    }
  end

  # Calculate the daily rate for a billing tier
  def calculate_daily_rate(billing_tier)
    monthly_price = billing_tier.monthly_price || 0
    per_user_price = billing_tier.per_user_price || 0
    current_users = @subscription.current_user_count

    # Calculate total monthly cost
    total_monthly = monthly_price + (per_user_price * current_users)
    
    # Convert to daily rate (assuming 30 days per month)
    total_monthly / 30.0
  end

  # Calculate remaining days in current billing period
  def calculate_remaining_days
    return 0 unless @subscription.current_period_end

    remaining_seconds = @subscription.current_period_end - Time.current
    remaining_seconds > 0 ? (remaining_seconds / 1.day).ceil : 0
  end

  # Get proration behavior for Stripe
  def get_proration_behavior
    # For immediate proration
    'create_prorations'
  end

  # Calculate proration timestamp for Stripe
  def get_proration_date
    Time.current.to_i
  end
end
