class UserInvitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :invited_by, class_name: 'User'
  
  # Find user by email (since there's no user_id column)
  def user
    tenant.users.find_by(email: email)
  end

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current).where(used_at: nil) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :used, -> { where.not(used_at: nil) }
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :cancelled, -> { where(status: 'cancelled') }

  before_create :generate_token, :set_expiry

  def expired?
    expires_at <= Time.current
  end

  def used?
    used_at.present?
  end

  def invitation_valid?
    !expired? && !used?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    config = BillingConfiguration.current
    self.expires_at = config.invitation_expiry_days.days.from_now
  end
end
