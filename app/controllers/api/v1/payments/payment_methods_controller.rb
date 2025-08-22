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
              Stripe.api_key = ENV['STRIPE_SECRET_KEY']
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
                  billing_details: pm.billing_details,
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

        # POST /api/v1/payments/payment_methods
        def create
          # Ensure tenant has a Stripe customer
          customer_id = ensure_tenant_customer
          
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Create payment method in Stripe
            # The frontend sends a payment method ID, not a token
            payment_method = Stripe::PaymentMethod.retrieve(payment_method_params[:card][:token])
            
            # Attach payment method to customer
            payment_method.attach(customer: customer_id)
            
            # Return the created payment method
            payment_method_data = {
              id: payment_method.id,
              type: payment_method.type,
              card: {
                brand: payment_method.card.brand,
                last4: payment_method.card.last4,
                exp_month: payment_method.card.exp_month,
                exp_year: payment_method.card.exp_year
              },
              billing_details: payment_method.billing_details,
              is_default: false
            }
            
            render_single_response(payment_method_data, status: :created)
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error creating payment method: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to create payment method',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
          end
        end

        # PUT /api/v1/payments/payment_methods/:id
        def update
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Update payment method in Stripe
            payment_method = Stripe::PaymentMethod.update(
              params[:id],
              {
                billing_details: payment_method_update_params[:billing_details],
                metadata: payment_method_update_params[:metadata]
              }.compact
            )
            
            # Return the updated payment method
            payment_method_data = {
              id: payment_method.id,
              type: payment_method.type,
              card: {
                brand: payment_method.card.brand,
                last4: payment_method.card.last4,
                exp_month: payment_method.card.exp_month,
                exp_year: payment_method.card.exp_year
              },
              billing_details: payment_method.billing_details,
              is_default: payment_method.id == get_customer_default_payment_method
            }
            
            render_single_response(payment_method_data)
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error updating payment method: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to update payment method',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
          end
        end

        # DELETE /api/v1/payments/payment_methods/:id
        def destroy
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Detach payment method from customer
            payment_method = Stripe::PaymentMethod.retrieve(params[:id])
            payment_method.detach
            
            head :no_content
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error deleting payment method: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to delete payment method',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
          end
        end

        # POST /api/v1/payments/payment_methods/:id/default
        def set_default
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Set payment method as default for customer
            customer = Stripe::Customer.update(
              Current.tenant.stripe_customer_id,
              invoice_settings: {
                default_payment_method: params[:id]
              }
            )
            
            head :ok
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error setting default payment method: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to set default payment method',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
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

        def ensure_tenant_customer
          if Current.tenant.stripe_customer_id.present?
            Current.tenant.stripe_customer_id
          else
            # Create Stripe customer for tenant
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            customer = Stripe::Customer.create(
              email: Current.tenant.email,
              name: Current.tenant.name,
              metadata: {
                tenant_id: Current.tenant.id,
                tenant_slug: Current.tenant.slug
              }
            )
            
            # Update tenant with Stripe customer ID
            Current.tenant.update!(stripe_customer_id: customer.id)
            customer.id
          end
        end

        def payment_method_params
          params.require(:payment_method).permit(
            :type,
            card: [:token],
            billing_details: [:name, :email, :phone, address: [:line1, :line2, :city, :state, :postal_code, :country]]
          )
        end

        def payment_method_update_params
          params.require(:payment_method).permit(
            billing_details: [:name, :email, :phone, address: [:line1, :line2, :city, :state, :postal_code, :country]],
            metadata: {}
          )
        end
      end
    end
  end
end
