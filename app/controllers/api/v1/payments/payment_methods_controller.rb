module Api
  module V1
    module Payments
      class PaymentMethodsController < BaseController
        before_action :authenticate_user!

        # GET /api/v1/payments/payment_methods
        def index
          # Get payment methods for the current tenant's Stripe customer
          if Current.tenant.stripe_customer_id.present?
            begin
              stripe_service = StripeService.new(Current.tenant)
              payment_methods = Stripe::PaymentMethod.list(
                customer: Current.tenant.stripe_customer_id,
                type: 'card'
              )

              payment_methods_data = payment_methods.data.map do |pm|
                {
                  id: pm.id,
                  type: pm.type,
                  card: {
                    brand: pm.card.brand,
                    last4: pm.card.last4,
                    exp_month: pm.card.exp_month,
                    exp_year: pm.card.exp_year
                  },
                  is_default: pm.id == get_customer_default_payment_method
                }
              end

              render_single_response(payment_methods_data)
            rescue Stripe::StripeError => e
              Rails.logger.error "Stripe error fetching payment methods: #{e.message}"
              render_error_response(
                error_code: 'stripe_error',
                message: 'Failed to fetch payment methods',
                details: { stripe_error: e.message },
                status: :unprocessable_entity
              )
            end
          else
            # No Stripe customer yet, return empty array
            render_single_response([])
          end
        end

        private

        def get_customer_default_payment_method
          return nil unless Current.tenant.stripe_customer_id.present?
          
          begin
            customer = Stripe::Customer.retrieve(Current.tenant.stripe_customer_id)
            customer.invoice_settings.default_payment_method
          rescue Stripe::StripeError => e
            Rails.logger.error "Error retrieving customer default payment method: #{e.message}"
            nil
          end
        end
      end
    end
  end
end
