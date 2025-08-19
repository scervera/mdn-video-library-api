class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :curriculums, dependent: :destroy
  has_many :chapters, dependent: :destroy
  has_many :lessons, dependent: :destroy
  has_many :user_progress, dependent: :destroy
  has_many :lesson_progress, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :billing_tiers, dependent: :destroy
  has_many :tenant_subscriptions, dependent: :destroy
  has_many :user_invitations, dependent: :destroy
  has_one :stripe_connect_account, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

  before_create :set_default_branding

  def full_domain
    domain.presence || "#{slug}.curriculum.cerveras.com"
  end

  def admin_user
    users.find_by(role: 'admin')
  end

  def current_subscription
    tenant_subscriptions.active.first
  end

  def trial?
    current_subscription&.trial?
  end

  def trial_expired?
    current_subscription&.trial_expired?
  end

  def can_add_user?
    return true unless current_subscription
    current_subscription.can_add_user?
  end

  def user_count
    users.count
  end

  def active_user_count
    user_subscriptions.active.count
  end

  def user_subscriptions
    UserSubscription.joins(:tenant_subscription).where(tenant_subscriptions: { tenant_id: id })
  end

  private

  def set_default_branding
    self.branding_settings ||= {
      'primary_color' => '#3B82F6',
      'secondary_color' => '#1F2937',
      'accent_color' => '#10B981',
      'company_name' => name
    }
  end
end
