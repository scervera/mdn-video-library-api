class TenantUsage < ApplicationRecord
  belongs_to :tenant

  validates :month, presence: true
  validates :storage_gb, :bandwidth_gb, :processing_minutes, :api_calls, 
            numericality: { greater_than_or_equal_to: 0 }

  # Get current month's usage
  def self.current_month(tenant)
    find_or_create_by(tenant: tenant, month: Date.current.beginning_of_month)
  end

  # Update usage from Cloudflare Stream
  def update_from_stream_usage(stream_usage)
    update!(
      storage_gb: stream_usage['storage_gb'] || 0,
      bandwidth_gb: stream_usage['bandwidth_gb'] || 0,
      processing_minutes: stream_usage['processing_minutes'] || 0
    )
  end

  # Calculate total cost based on usage
  def calculate_cost
    # This would integrate with your pricing logic
    base_cost = 29.99 # Starter tier base cost
    
    # Add overage charges
    storage_overage = [storage_gb - 10, 0].max * 0.10 # $0.10/GB over 10GB
    bandwidth_overage = [bandwidth_gb - 100, 0].max * 0.05 # $0.05/GB over 100GB
    processing_overage = [processing_minutes - 1000, 0].max * 0.01 # $0.01/minute over 1000
    
    base_cost + storage_overage + bandwidth_overage + processing_overage
  end

  # Check if tenant is within limits
  def within_limits?
    storage_gb <= 10 && bandwidth_gb <= 100 && processing_minutes <= 1000
  end

  # Get usage percentage for each metric
  def usage_percentages
    {
      storage: (storage_gb / 10.0 * 100).round(1),
      bandwidth: (bandwidth_gb / 100.0 * 100).round(1),
      processing: (processing_minutes / 1000.0 * 100).round(1)
    }
  end
end
