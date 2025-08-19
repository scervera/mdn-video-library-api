require 'net/http'
require 'json'

class CloudflareDnsService
  include ActiveSupport::Configurable

  config_accessor :api_token, :zone_id, :domain

  def initialize
    config = Rails.application.config_for(:cloudflare)
    @api_token = config[:dns_api_token]
    @zone_id = config[:zone_id]
    @domain = config[:domain]
  end

  # Check if a slug is available (not already in use)
  def slug_available?(slug)
    return false unless valid_slug_format?(slug)
    
    # Check if slug already exists in our database
    return false if Tenant.exists?(slug: slug)
    
    # If Cloudflare credentials are not configured, only check database
    return true unless cloudflare_configured?
    
    # Check if DNS record already exists in Cloudflare
    !dns_record_exists?(slug)
  end

  # Create a CNAME record for the slug
  def create_slug(slug)
    return { success: false, error: 'Invalid slug format' } unless valid_slug_format?(slug)
    return { success: false, error: 'Slug already exists' } unless slug_available?(slug)

    # If Cloudflare credentials are not configured, return mock success
    unless cloudflare_configured?
      return { success: true, record_id: "mock_record_#{SecureRandom.hex(8)}" }
    end

    begin
      response = create_dns_record(slug)
      
      if response[:success]
        { success: true, record_id: response[:record_id] }
      else
        { success: false, error: response[:error] }
      end
    rescue => e
      { success: false, error: "DNS creation failed: #{e.message}" }
    end
  end

  # Delete a CNAME record for the slug
  def delete_slug(slug)
    begin
      record_id = get_dns_record_id(slug)
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

  # Get DNS record ID for a slug
  def get_dns_record_id(slug)
    records = list_dns_records
    record = records.find { |r| r['name'] == "#{slug}.#{@domain}" }
    record&.dig('id')
  end

  private

  def valid_slug_format?(slug)
    return false if slug.blank?
    return false if slug.length < 3 || slug.length > 63
    
    # Must start and end with alphanumeric
    return false unless slug.match?(/^[a-z0-9]/)
    return false unless slug.match?(/[a-z0-9]$/)
    
    # Can contain alphanumeric and hyphens, but no consecutive hyphens
    return false unless slug.match?(/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/)
    return false if slug.include?('--')
    
    # Check for reserved slugs
    reserved_slugs = %w[www api admin mail smtp pop imap ftp ssh sftp]
    return false if reserved_slugs.include?(slug.downcase)
    
    true
  end

  def dns_record_exists?(slug)
    record_id = get_dns_record_id(slug)
    record_id.present?
  end

  def create_dns_record(slug)
    uri = URI("https://api.cloudflare.com/client/v4/zones/#{@zone_id}/dns_records")
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@api_token}"
    request['Content-Type'] = 'application/json'
    
    payload = {
      type: 'CNAME',
      name: "#{slug}.#{@domain}",
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

  private

  def cloudflare_configured?
    @api_token.present? && @zone_id.present?
  end
end
