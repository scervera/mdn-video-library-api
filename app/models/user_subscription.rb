class UserSubscription < ApplicationRecord
  belongs_to :tenant_subscription
  belongs_to :user
  belongs_to :tenant

  validates :status, inclusion: { in: %w[active canceled] }
  validates :monthly_price, numericality: { greater_than: 0 }
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  validates :user_id, uniqueness: { scope: :tenant_subscription_id }

  scope :active, -> { where(status: 'active') }

  def active?
    status == 'active'
  end

  def cancel!
    update!(status: 'canceled')
  end
end
