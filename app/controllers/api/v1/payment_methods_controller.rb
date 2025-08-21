class Api::V1::PaymentMethodsController < Api::V1::BaseController
  before_action :ensure_admin_user

  # GET /api/v1/payment_methods
  def index
    stripe_service = StripeService.new(Current.tenant)
    
    begin
      payment_methods = stripe_service.list_customer_payment_methods(Current.tenant.stripe_customer_id)
      
      payment_methods_data = payment_methods.data.map do |pm|
        {
          id: pm.id,
          type: pm.type,
          card: pm.card ? {
            brand: pm.card.brand,
            last4: pm.card.last4,
            exp_month: pm.card.exp_month,
            exp_year: pm.card.exp_year
          } : nil,
          billing_details: {
            name: pm.billing_details.name,
            email: pm.billing_details.email
          },
          created: pm.created
        }
      end

      render_list_response(payment_methods_data)
    rescue Stripe::StripeError => e
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to retrieve payment methods',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    end
  end

  # POST /api/v1/payment_methods
  def create
    stripe_service = StripeService.new(Current.tenant)
    
    begin
      # Create payment method
      payment_method = stripe_service.create_payment_method(
        type: 'card',
        card: payment_method_params[:card]
      )

      # Attach to customer
      stripe_service.add_payment_method_to_customer(
        Current.tenant.stripe_customer_id,
        payment_method.id
      )

      payment_method_data = {
        id: payment_method.id,
        type: payment_method.type,
        card: {
          brand: payment_method.card.brand,
          last4: payment_method.card.last4,
          exp_month: payment_method.card.exp_month,
          exp_year: payment_method.card.exp_year
        },
        billing_details: {
          name: payment_method.billing_details.name,
          email: payment_method.billing_details.email
        }
      }

      render_single_response(payment_method_data, status: :created)
    rescue Stripe::StripeError => e
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to create payment method',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    end
  end

  # POST /api/v1/payment_methods/:id/set_default
  def set_default
    stripe_service = StripeService.new(Current.tenant)
    
    begin
      stripe_service.set_default_payment_method(
        Current.tenant.stripe_customer_id,
        params[:id]
      )

      render_action_response(message: 'Payment method set as default')
    rescue Stripe::StripeError => e
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to set default payment method',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    end
  end

  # DELETE /api/v1/payment_methods/:id
  def destroy
    stripe_service = StripeService.new(Current.tenant)
    
    begin
      stripe_service.detach_payment_method(params[:id])
      
      render_action_response(message: 'Payment method removed successfully')
    rescue Stripe::StripeError => e
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to remove payment method',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    end
  end

  # POST /api/v1/payment_methods/setup_intent
  def setup_intent
    stripe_service = StripeService.new(Current.tenant)
    
    begin
      setup_intent = stripe_service.create_setup_intent(
        Current.tenant.stripe_customer_id
      )

      render_single_response({
        client_secret: setup_intent.client_secret,
        id: setup_intent.id
      })
    rescue Stripe::StripeError => e
      render_error_response(
        error_code: 'stripe_error',
        message: 'Failed to create setup intent',
        details: { stripe_error: e.message },
        status: :unprocessable_entity
      )
    end
  end

  private

  def payment_method_params
    params.require(:payment_method).permit(card: [:number, :exp_month, :exp_year, :cvc])
  end

  def ensure_admin_user
    unless current_user&.admin?
      render_forbidden_error('Admin access required')
    end
  end
end
