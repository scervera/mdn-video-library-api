module Api
  module V1
    module Payments
      class InvoicesController < BaseController
        before_action :authenticate_user!

        # GET /api/v1/payments/invoices
        def index
          # Get invoices for the current tenant's Stripe customer
          if Current.tenant.stripe_customer_id.present?
            begin
              invoices = Stripe::Invoice.list(
                customer: Current.tenant.stripe_customer_id,
                limit: 20
              )

              invoices_data = invoices.data.map do |invoice|
                {
                  id: invoice.id,
                  number: invoice.number,
                  amount_due: invoice.amount_due,
                  amount_paid: invoice.amount_paid,
                  currency: invoice.currency,
                  status: invoice.status,
                  created: Time.at(invoice.created),
                  due_date: invoice.due_date ? Time.at(invoice.due_date) : nil,
                  period_start: invoice.period_start ? Time.at(invoice.period_start) : nil,
                  period_end: invoice.period_end ? Time.at(invoice.period_end) : nil,
                  subscription: invoice.subscription_id,
                  lines: invoice.lines.data.map do |line|
                    {
                      id: line.id,
                      description: line.description,
                      amount: line.amount,
                      currency: line.currency,
                      quantity: line.quantity
                    }
                  end
                }
              end

              render_single_response(invoices_data)
            rescue Stripe::StripeError => e
              Rails.logger.error "Stripe error fetching invoices: #{e.message}"
              render_error_response(
                error_code: 'stripe_error',
                message: 'Failed to fetch invoices',
                details: { stripe_error: e.message },
                status: :unprocessable_entity
              )
            end
          else
            # No Stripe customer yet, return empty array
            render_single_response([])
          end
        end
      end
    end
  end
end
