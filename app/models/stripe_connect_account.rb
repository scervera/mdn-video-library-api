class StripeConnectAccount < ApplicationRecord
  belongs_to :tenant

  validates :account_id, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending active restricted] }

  scope :active, -> { where(status: 'active') }
  scope :pending, -> { where(status: 'pending') }

  def active?
    status == 'active'
  end

  def ready_for_payments?
    active? && charges_enabled? && payouts_enabled?
  end

  def update_from_stripe!(stripe_account)
    update!(
      status: stripe_account.status,
      charges_enabled: stripe_account.charges_enabled,
      payouts_enabled: stripe_account.payouts_enabled
    )
  end
end
