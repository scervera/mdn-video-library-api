class User < ApplicationRecord
  belongs_to :tenant
  has_many :user_progress, dependent: :destroy
  has_many :lesson_progress, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :user_invitations_sent, class_name: 'UserInvitation', foreign_key: 'invited_by_id', dependent: :destroy
  has_many :user_invitations, dependent: :destroy
  has_many :user_subscriptions, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: { scope: :tenant_id }
  validates :username, presence: true, uniqueness: { scope: :tenant_id }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, inclusion: { in: %w[admin user] }

  scope :admins, -> { where(role: 'admin') }
  scope :regular_users, -> { where(role: 'user') }

  def admin?
    role == 'admin'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def enrolled_in?(curriculum)
    user_progress.exists?(curriculum: curriculum)
  end

  def completed_chapters_count(curriculum)
    user_progress.where(curriculum: curriculum, completed: true).count
  end

  def completed_lessons_count(curriculum)
    lesson_progress.joins(lesson: :chapter)
                   .where(chapters: { curriculum: curriculum }, completed: true)
                   .count
  end

  def current_subscription
    user_subscriptions.active.first
  end

  def has_active_subscription?
    current_subscription.present?
  end
end
