class TenantSubscription < ApplicationRecord
  belongs_to :tenant
  belongs_to :billing_tier
  has_many :user_subscriptions, dependent: :destroy

  validates :status, inclusion: { in: %w[trial active past_due canceled] }
  validates :trial_ends_at, presence: true, if: :trial?
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  scope :active, -> { where(status: %w[trial active]) }
  scope :trial, -> { where(status: 'trial') }
  scope :expired_trials, -> { trial.where('trial_ends_at <= ?', Time.current) }

  before_create :set_trial_period, if: :trial?

  def trial?
    status == 'trial'
  end

  def active?
    %w[trial active].include?(status)
  end

  def trial_expired?
    trial? && trial_ends_at <= Time.current
  end

  def current_user_count
    user_subscriptions.active.count
  end

  def can_add_user?
    return true if billing_tier.unlimited_users?
    current_user_count < billing_tier.user_limit
  end

  def days_until_trial_expires
    return nil unless trial?
    [(trial_ends_at - Time.current).to_i / 1.day, 0].max
  end

  private

  def set_trial_period
    config = BillingConfiguration.current
    self.trial_ends_at = config.trial_duration_days.days.from_now
  end
end
