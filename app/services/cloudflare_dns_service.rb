require 'net/http'
require 'json'

class CloudflareDnsService
  include ActiveSupport::Configurable

  config_accessor :api_token, :zone_id, :domain

  def initialize
    @api_token = Rails.application.credentials.cloudflare[:api_token]
    @zone_id = Rails.application.credentials.cloudflare[:zone_id]
    @domain = Rails.application.credentials.cloudflare[:domain] || 'cerveras.com'
  end

  # Check if a subdomain is available (not already in use)
  def subdomain_available?(subdomain)
    return false unless valid_subdomain_format?(subdomain)
    
    # Check if subdomain already exists in our database
    return false if Tenant.exists?(subdomain: subdomain)
    
    # Check if DNS record already exists in Cloudflare
    !dns_record_exists?(subdomain)
  end

  # Create a CNAME record for the subdomain
  def create_subdomain(subdomain)
    return { success: false, error: 'Invalid subdomain format' } unless valid_subdomain_format?(subdomain)
    return { success: false, error: 'Subdomain already exists' } unless subdomain_available?(subdomain)

    begin
      response = create_dns_record(subdomain)
      
      if response[:success]
        { success: true, record_id: response[:record_id] }
      else
        { success: false, error: response[:error] }
      end
    rescue => e
      { success: false, error: "DNS creation failed: #{e.message}" }
    end
  end

  # Delete a CNAME record for the subdomain
  def delete_subdomain(subdomain)
    begin
      record_id = get_dns_record_id(subdomain)
      return { success: false, error: 'DNS record not found' } unless record_id

      response = delete_dns_record(record_id)
      
      if response[:success]
        { success: true }
      else
        { success: false, error: response[:error] }
      end
    rescue => e
      { success: false, error: "DNS deletion failed: #{e.message}" }
    end
  end

  # Get DNS record ID for a subdomain
  def get_dns_record_id(subdomain)
    records = list_dns_records
    record = records.find { |r| r['name'] == "#{subdomain}.#{@domain}" }
    record&.dig('id')
  end

  private

  def valid_subdomain_format?(subdomain)
    return false if subdomain.blank?
    return false if subdomain.length < 3 || subdomain.length > 63
    
    # Must start and end with alphanumeric
    return false unless subdomain.match?(/^[a-z0-9]/)
    return false unless subdomain.match?(/[a-z0-9]$/)
    
    # Can contain alphanumeric and hyphens, but no consecutive hyphens
    return false unless subdomain.match?(/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/)
    return false if subdomain.include?('--')
    
    # Check for reserved subdomains
    reserved_subdomains = %w[www api admin mail smtp pop imap ftp ssh sftp]
    return false if reserved_subdomains.include?(subdomain.downcase)
    
    true
  end

  def dns_record_exists?(subdomain)
    record_id = get_dns_record_id(subdomain)
    record_id.present?
  end

  def create_dns_record(subdomain)
    uri = URI("https://api.cloudflare.com/client/v4/zones/#{@zone_id}/dns_records")
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@api_token}"
    request['Content-Type'] = 'application/json'
    
    payload = {
      type: 'CNAME',
      name: "#{subdomain}.#{@domain}",
      content: "#{@domain}",
      ttl: 1, # Auto TTL
      proxied: false # DNS only, not proxied through Cloudflare
    }
    
    request.body = payload.to_json
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      result = JSON.parse(response.body)
      if result['success']
        { success: true, record_id: result['result']['id'] }
      else
        { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
      end
    else
      { success: false, error: "HTTP #{response.code}: #{response.body}" }
    end
  end

  def delete_dns_record(record_id)
    uri = URI("https://api.cloudflare.com/client/v4/zones/#{@zone_id}/dns_records/#{record_id}")
    
    request = Net::HTTP::Delete.new(uri)
    request['Authorization'] = "Bearer #{@api_token}"
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      result = JSON.parse(response.body)
      if result['success']
        { success: true }
      else
        { success: false, error: result['errors']&.first&.dig('message') || 'Unknown error' }
      end
    else
      { success: false, error: "HTTP #{response.code}: #{response.body}" }
    end
  end

  def list_dns_records
    uri = URI("https://api.cloudflare.com/client/v4/zones/#{@zone_id}/dns_records")
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@api_token}"
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      result = JSON.parse(response.body)
      if result['success']
        result['result']
      else
        []
      end
    else
      []
    end
  end
end
