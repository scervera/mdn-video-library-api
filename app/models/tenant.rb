class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :curriculums, dependent: :destroy
  has_many :chapters, dependent: :destroy
  has_many :lessons, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :user_progresses, dependent: :destroy
  has_many :lesson_progresses, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }
  
  # DNS record management
  attr_accessor :dns_record_id
  
  before_create :create_dns_record
  before_destroy :delete_dns_record
  
  # Custom validation for subdomain availability
  validate :subdomain_availability, on: :create

  # Branding settings
  def branding_settings
    super || default_branding_settings
  end

  def primary_color
    branding_settings['primary_color'] || '#3B82F6'
  end

  def secondary_color
    branding_settings['secondary_color'] || '#1F2937'
  end

  def accent_color
    branding_settings['accent_color'] || '#F59E0B'
  end

  def logo_url
    branding_settings['logo_url']
  end

  def company_name
    branding_settings['company_name'] || name
  end

  def full_domain
    domain.presence || "#{subdomain}.curriculum-library-api.cerveras.com"
  end

  # DNS management methods
  def create_dns_record
    return if Rails.env.test? # Skip DNS operations in test environment
    
    dns_service = CloudflareDnsService.new
    result = dns_service.create_subdomain(subdomain)
    
    if result[:success]
      self.dns_record_id = result[:record_id]
    else
      errors.add(:subdomain, "DNS creation failed: #{result[:error]}")
      throw(:abort)
    end
  end

  def delete_dns_record
    return if Rails.env.test? # Skip DNS operations in test environment
    return unless dns_record_id.present?
    
    dns_service = CloudflareDnsService.new
    result = dns_service.delete_subdomain(subdomain)
    
    unless result[:success]
      Rails.logger.error "Failed to delete DNS record for #{subdomain}: #{result[:error]}"
    end
  end

  def subdomain_availability
    return if Rails.env.test? # Skip DNS validation in test environment
    
    dns_service = CloudflareDnsService.new
    unless dns_service.subdomain_available?(subdomain)
      errors.add(:subdomain, "is not available")
    end
  end

  private

  def default_branding_settings
    {
      'primary_color' => '#3B82F6',
      'secondary_color' => '#1F2937',
      'accent_color' => '#F59E0B',
      'company_name' => name
    }
  end
end
