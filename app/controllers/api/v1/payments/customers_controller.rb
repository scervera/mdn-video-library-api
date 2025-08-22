# app/controllers/api/v1/payments/customers_controller.rb
module Api
  module V1
    module Payments
      class CustomersController < BaseController
        before_action :authenticate_user!

        # GET /api/v1/payments/customer
        def show
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Get or create customer for the current tenant
            customer_id = ensure_tenant_customer
            
            # Retrieve customer from Stripe
            customer = Stripe::Customer.retrieve(customer_id)
            
            customer_data = {
              id: customer.id,
              email: customer.email,
              name: customer.name,
              phone: customer.phone,
              address: customer.address,
              metadata: customer.metadata,
              created: Time.at(customer.created),
              default_source: customer.default_source,
              invoice_settings: {
                default_payment_method: customer.invoice_settings.default_payment_method
              }
            }
            
            render_single_response(customer_data)
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error retrieving customer: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to retrieve customer',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
          end
        end

        # POST /api/v1/payments/customer
        def create
          begin
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
            
            # Create customer in Stripe
            customer = Stripe::Customer.create(
              email: customer_params[:email],
              name: customer_params[:name],
              phone: customer_params[:phone],
              address: customer_params[:address],
              metadata: {
                tenant_id: Current.tenant.id,
                tenant_slug: Current.tenant.slug
              }
            )
            
            # Update tenant with Stripe customer ID
            Current.tenant.update!(stripe_customer_id: customer.id)
            
            customer_data = {
              id: customer.id,
              email: customer.email,
              name: customer.name,
              phone: customer.phone,
              address: customer.address,
              metadata: customer.metadata,
              created: Time.at(customer.created),
              default_source: customer.default_source,
              invoice_settings: {
                default_payment_method: customer.invoice_settings.default_payment_method
              }
            }
            
            render_single_response(customer_data, status: :created)
          rescue Stripe::StripeError => e
            Rails.logger.error "Stripe error creating customer: #{e.message}"
            render_error_response(
              error_code: 'stripe_error',
              message: 'Failed to create customer',
              details: { stripe_error: e.message },
              status: :unprocessable_entity
            )
          end
        end

        private

        def ensure_tenant_customer
          if Current.tenant.stripe_customer_id.present?
            Current.tenant.stripe_customer_id
          else
            # Create Stripe customer for tenant
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

        def customer_params
          params.require(:customer).permit(
            :email, :name, :phone,
            address: [:line1, :line2, :city, :state, :postal_code, :country]
          )
        end
      end
    end
  end
end
