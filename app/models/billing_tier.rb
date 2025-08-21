class BillingTier < ApplicationRecord
  belongs_to :tenant
  has_many :tenant_subscriptions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :monthly_price, numericality: { greater_than_or_equal_to: 0 }
  validates :per_user_price, numericality: { greater_than_or_equal_to: 0 }
  validates :user_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :stripe_price_id, uniqueness: true, allow_nil: true

  scope :active, -> { joins(:tenant_subscriptions).where(tenant_subscriptions: { status: %w[trial active] }) }

  def trial?
    name.downcase == 'trial'
  end

  def unlimited_users?
    user_limit.nil?
  end

  def has_per_user_billing?
    per_user_price > 0
  end

  def total_price_for_users(user_count)
    monthly_price + (per_user_price * user_count)
  end

  def stripe_price_configured?
    stripe_price_id.present?
  end
end
