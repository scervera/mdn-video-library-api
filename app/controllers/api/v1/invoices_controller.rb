class Api::V1::InvoicesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_stripe_connected
  before_action :set_invoice, only: [:show, :pay, :void, :mark_uncollectible, :send_invoice]

  # GET /api/v1/invoices
  def index
    customer_id = params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    invoices = stripe_service.list_invoices(
      customer: customer_id,
      limit: params[:limit] || 10,
      starting_after: params[:starting_after]
    )
    
    render json: {
      customer_id: customer_id,
      invoices: invoices.data.map { |invoice| format_invoice_response(invoice) },
      has_more: invoices.has_more
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch invoices: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/invoices/:id
  def show
    render json: { invoice: format_invoice_response(@invoice) }
  rescue Stripe::StripeError => e
    render json: { error: "Invoice not found: #{e.message}" }, status: :not_found
  end

  # POST /api/v1/invoices
  def create
    customer_id = invoice_params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    invoice = stripe_service.create_invoice(
      customer: customer_id,
      description: invoice_params[:description],
      metadata: invoice_params[:metadata] || {},
      auto_advance: invoice_params[:auto_advance] || true,
      collection_method: invoice_params[:collection_method] || 'charge_automatically'
    )

    # Add invoice items if provided
    if invoice_params[:items].present?
      invoice_params[:items].each do |item|
        stripe_service.create_invoice_item(
          customer: customer_id,
          invoice: invoice.id,
          amount: item[:amount],
          currency: item[:currency] || 'usd',
          description: item[:description]
        )
      end
      
      # Refresh the invoice to include the items
      invoice = stripe_service.retrieve_invoice(invoice.id)
    end

    render json: { 
      invoice: format_invoice_response(invoice),
      message: "Invoice created successfully"
    }, status: :created
  rescue Stripe::StripeError => e
    render json: { error: "Failed to create invoice: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/invoices/:id/pay
  def pay
    if @invoice.status == 'paid'
      return render json: { error: "Invoice is already paid" }, status: :unprocessable_entity
    end

    paid_invoice = stripe_service.pay_invoice(
      @invoice.id,
      payment_method: params[:payment_method],
      source: params[:source]
    )

    render json: { 
      invoice: format_invoice_response(paid_invoice),
      message: "Invoice payment processed"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to process payment: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/invoices/:id/void
  def void
    if @invoice.status == 'paid'
      return render json: { error: "Cannot void a paid invoice" }, status: :unprocessable_entity
    end

    voided_invoice = stripe_service.void_invoice(@invoice.id)

    render json: { 
      invoice: format_invoice_response(voided_invoice),
      message: "Invoice voided successfully"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to void invoice: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/invoices/:id/mark_uncollectible
  def mark_uncollectible
    marked_invoice = stripe_service.mark_invoice_uncollectible(@invoice.id)

    render json: { 
      invoice: format_invoice_response(marked_invoice),
      message: "Invoice marked as uncollectible"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to mark invoice as uncollectible: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/invoices/:id/send
  def send_invoice
    sent_invoice = stripe_service.send_invoice(@invoice.id)

    render json: { 
      invoice: format_invoice_response(sent_invoice),
      message: "Invoice sent successfully"
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to send invoice: #{e.message}" }, status: :unprocessable_entity
  end

  # GET /api/v1/invoices/upcoming
  def upcoming
    customer_id = params[:customer_id] || current_user.stripe_customer_id
    
    unless customer_id
      return render json: { error: "No Stripe customer found" }, status: :not_found
    end

    upcoming_invoice = stripe_service.retrieve_upcoming_invoice(
      customer: customer_id,
      subscription: params[:subscription_id]
    )

    render json: { 
      upcoming_invoice: format_invoice_response(upcoming_invoice)
    }
  rescue Stripe::StripeError => e
    render json: { error: "Failed to fetch upcoming invoice: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_invoice
    @invoice = stripe_service.retrieve_invoice(params[:id])
  end

  def invoice_params
    params.permit(:customer_id, :description, :auto_advance, :collection_method, metadata: {}, items: [:amount, :currency, :description])
  end

  def format_invoice_response(invoice)
    {
      id: invoice.id,
      customer: invoice.customer,
      subscription: invoice.subscription,
      status: invoice.status,
      total: invoice.total,
      subtotal: invoice.subtotal,
      tax: invoice.tax,
      amount_due: invoice.amount_due,
      amount_paid: invoice.amount_paid,
      amount_remaining: invoice.amount_remaining,
      currency: invoice.currency,
      description: invoice.description,
      hosted_invoice_url: invoice.hosted_invoice_url,
      invoice_pdf: invoice.invoice_pdf,
      created: invoice.created,
      due_date: invoice.due_date,
      period_start: invoice.period_start,
      period_end: invoice.period_end,
      metadata: invoice.metadata&.to_h || {},
      lines: invoice.lines&.data&.map { |line| format_invoice_line(line) } || [],
      payment_intent: invoice.payment_intent ? {
        id: invoice.payment_intent.id,
        status: invoice.payment_intent.status,
        client_secret: invoice.payment_intent.client_secret
      } : nil
    }
  end

  def format_invoice_line(line)
    {
      id: line.id,
      amount: line.amount,
      currency: line.currency,
      description: line.description,
      quantity: line.quantity,
      type: line.type,
      period: {
        start: line.period&.start,
        end: line.period&.end
      }
    }
  end

  def stripe_service
    @stripe_service ||= StripeService.new(Current.tenant)
  end

  def ensure_stripe_connected
    unless Current.tenant.stripe_connect_account&.charges_enabled?
      render json: { 
        error: "Stripe account not connected or not enabled for charges" 
      }, status: :unprocessable_entity
    end
  end
end
