# Custom delivery method for Brevo API
class BrevoDeliveryMethod
  def initialize(settings = {})
    @api_key = ENV['BREVO_API_KEY']
  end

  def deliver!(mail)
    # Extract email data
    to_email = mail.to.first
    subject = mail.subject
    html_content = mail.html_part&.body&.to_s || mail.body.to_s
    text_content = mail.text_part&.body&.to_s
    
    # Parse sender information
    from_email = mail.from.first
    from_name = mail.from.first.split('@').first
    
    # Create the request payload matching the successful curl format
    payload = {
      sender: {
        name: from_name,
        email: from_email
      },
      to: [
        {
          email: to_email,
          name: to_email.split('@').first
        }
      ],
      subject: subject,
      htmlContent: html_content
    }
    
    # Add text content if available
    payload[:textContent] = text_content if text_content.present?

    # Make the API request
    uri = URI('https://api.brevo.com/v3/smtp/email')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['accept'] = 'application/json'
    request['api-key'] = @api_key
    request['content-type'] = 'application/json'
    request.body = payload.to_json

    begin
      response = http.request(request)
      
      if response.code == '201' || response.code == '200'
        result = JSON.parse(response.body)
        Rails.logger.info "Email sent successfully via Brevo API: #{result['messageId']}"
        result
      else
        Rails.logger.error "Failed to send email via Brevo API: #{response.code} - #{response.body}"
        raise "Brevo API error: #{response.code} - #{response.body}"
      end
    rescue => e
      Rails.logger.error "Failed to send email via Brevo API: #{e.message}"
      raise e
    end
  end
end

# Register the custom delivery method
ActionMailer::Base.add_delivery_method :brevo, BrevoDeliveryMethod
