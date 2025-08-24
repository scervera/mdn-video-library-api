require 'net/http'
require 'json'

class CloudflareDnsService
  include ActiveSupport::Configurable

  config_accessor :subdomain

  def initialize
    config = Rails.application.config_for(:cloudflare)
    @subdomain = config[:subdomain]
  end

  # Check if a slug is available (not already in use)
  def slug_available?(slug)
    return false unless valid_slug_format?(slug)
    
    # Check if slug already exists in our database
    return false if Tenant.exists?(slug: slug)
    
    # For path-based multitenancy, we only need to check the database
    true
  end

  # Create a slug (no DNS operations needed for path-based multitenancy)
  def create_slug(slug)
    return { success: false, error: 'Invalid slug format' } unless valid_slug_format?(slug)
    return { success: false, error: 'Slug already exists' } unless slug_available?(slug)

    # For path-based multitenancy, no DNS operations are needed
    { success: true, record_id: "path_based_#{SecureRandom.hex(8)}" }
  end

  # Delete a slug (no DNS operations needed for path-based multitenancy)
  def delete_slug(slug)
    # For path-based multitenancy, no DNS operations are needed
    { success: true }
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
end
