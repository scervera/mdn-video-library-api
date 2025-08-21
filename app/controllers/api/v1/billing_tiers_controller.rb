class Api::V1::BillingTiersController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  # GET /api/v1/billing_tiers
  def index
    config = BillingConfiguration.current
    tiers = config.tiers.map do |tier_key, tier_data|
      {
        id: tier_key,
        name: tier_data['name'],
        monthly_price: tier_data['monthly_price'],
        per_user_price: tier_data['per_user_price'],
        user_limit: tier_data['user_limit'],
        features: tier_data['features'],
        description: tier_data['description']
      }
    end

    meta = {
      invitation_expiry_days: config.invitation_expiry_days,
      trial_duration_days: config.trial_duration_days,
      supported_payment_methods: config.supported_payment_methods,
      currencies: config.currencies
    }

    render_list_response(tiers, meta: meta)
  end

  # GET /api/v1/billing_tiers/:id
  def show
    config = BillingConfiguration.current
    tier_data = config.get_tier(params[:id])

    if tier_data.nil?
      render_not_found_error('Billing tier')
      return
    end

    tier = {
      id: params[:id],
      name: tier_data['name'],
      monthly_price: tier_data['monthly_price'],
      per_user_price: tier_data['per_user_price'],
      user_limit: tier_data['user_limit'],
      features: tier_data['features'],
      description: tier_data['description']
    }

    render_single_response(tier)
  end
end
