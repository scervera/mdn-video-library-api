class Api::V1::StripeConnectController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_admin_or_owner

  # GET /api/v1/stripe_connect/status
  def status
    connect_account = Current.tenant.stripe_connect_account
    
    if connect_account
      # Update status from Stripe
      stripe_service.update_connect_account_status(connect_account)
      
      render json: {
        connected: true,
        account_id: connect_account.account_id,
        status: connect_account.status,
        charges_enabled: connect_account.charges_enabled?,
        payouts_enabled: connect_account.payouts_enabled?,
        requirements: connect_account.requirements,
        capabilities: connect_account.capabilities,
        business_type: connect_account.business_type,
        country: connect_account.country
      }
    else
      render json: {
        connected: false,
        message: "No Stripe Connect account found"
      }
    end
  rescue Stripe::StripeError => e
    render json: { 
      error: "Failed to get connect status: #{e.message}" 
    }, status: :unprocessable_entity
  end

  # POST /api/v1/stripe_connect/authorize
  def authorize
    # Create Stripe Connect account if it doesn't exist
    unless Current.tenant.stripe_connect_account
      stripe_service.create_connect_account(Current.tenant)
    end

    # Generate authorization URL
    connect_account = Current.tenant.stripe_connect_account
    authorize_url = stripe_service.get_connect_account_link(connect_account)

    render json: {
      authorize_url: authorize_url,
      account_id: connect_account.account_id
    }
  rescue Stripe::StripeError => e
    render json: { 
      error: "Failed to create authorization URL: #{e.message}" 
    }, status: :unprocessable_entity
  end

  # GET /api/v1/stripe_connect/account_details
  def account_details
    connect_account = Current.tenant.stripe_connect_account
    
    unless connect_account
      return render json: { error: "No Stripe Connect account found" }, status: :not_found
    end

    # Get detailed account information from Stripe
    account = stripe_service.retrieve_connect_account(connect_account.account_id)
    
    render json: {
      account: {
        id: account.id,
        business_profile: account.business_profile,
        capabilities: account.capabilities,
        charges_enabled: account.charges_enabled,
        country: account.country,
        created: account.created,
        default_currency: account.default_currency,
        details_submitted: account.details_submitted,
        email: account.email,
        payouts_enabled: account.payouts_enabled,
        requirements: account.requirements,
        settings: account.settings,
        type: account.type,
        verification: account.verification
      }
    }
  rescue Stripe::StripeError => e
    render json: { 
      error: "Failed to get account details: #{e.message}" 
    }, status: :unprocessable_entity
  end

  # POST /api/v1/stripe_connect/refresh
  def refresh
    connect_account = Current.tenant.stripe_connect_account
    
    unless connect_account
      return render json: { error: "No Stripe Connect account found" }, status: :not_found
    end

    # Update account status from Stripe
    stripe_service.update_connect_account_status(connect_account)
    
    render json: {
      message: "Account status refreshed successfully",
      status: connect_account.status,
      charges_enabled: connect_account.charges_enabled?,
      payouts_enabled: connect_account.payouts_enabled?
    }
  rescue Stripe::StripeError => e
    render json: { 
      error: "Failed to refresh account: #{e.message}" 
    }, status: :unprocessable_entity
  end

  # DELETE /api/v1/stripe_connect/disconnect
  def disconnect
    connect_account = Current.tenant.stripe_connect_account
    
    unless connect_account
      return render json: { error: "No Stripe Connect account found" }, status: :not_found
    end

    # Delete the account from Stripe
    stripe_service.delete_connect_account(connect_account.account_id)
    
    # Remove from database
    connect_account.destroy

    render json: { message: "Stripe Connect account disconnected successfully" }
  rescue Stripe::StripeError => e
    render json: { 
      error: "Failed to disconnect account: #{e.message}" 
    }, status: :unprocessable_entity
  end

  private

  def stripe_service
    @stripe_service ||= StripeService.new(Current.tenant)
  end

  def ensure_admin_or_owner
    unless current_user.admin? || current_user.owner?
      render json: { error: "Access denied" }, status: :forbidden
    end
  end
end
