class BillingConfiguration
  include Singleton

  def self.current
    instance
  end

  def initialize
    load_configuration
  end

  def tiers
    @config['tiers']
  end

  def tier_names
    tiers.keys
  end

  def get_tier(tier_name)
    tiers[tier_name.to_s]
  end

  def trial_tier
    get_tier('trial')
  end

  def invitation_expiry_days
    @config['invitation_expiry_days']
  end

  def trial_duration_days
    @config['trial_duration_days']
  end

  def automatic_trial_conversion?
    @config['automatic_trial_conversion']
  end

  def supported_payment_methods
    @config['supported_payment_methods']
  end

  def currencies
    @config['currencies']
  end

  def reload!
    load_configuration
  end

  private

  def load_configuration
    config_file = Rails.root.join('config', 'billing_tiers.json')
    
    if File.exist?(config_file)
      @config = JSON.parse(File.read(config_file))
    else
      Rails.logger.error "Billing configuration file not found: #{config_file}"
      @config = default_configuration
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON in billing configuration: #{e.message}"
    @config = default_configuration
  end

  def default_configuration
    {
      'tiers' => {
        'trial' => {
          'name' => 'Trial',
          'duration_days' => 30,
          'user_limit' => 10,
          'monthly_price' => 0,
          'per_user_price' => 0,
          'features' => ['basic_access', 'up_to_10_users'],
          'description' => '30-day free trial with up to 10 users'
        }
      },
      'invitation_expiry_days' => 14,
      'trial_duration_days' => 30,
      'automatic_trial_conversion' => true,
      'supported_payment_methods' => ['card'],
      'currencies' => ['usd']
    }
  end
end
