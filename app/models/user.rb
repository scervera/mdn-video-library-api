class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :user_progress, dependent: :destroy
  has_many :lesson_progress, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Instance methods
  def completed_chapters_count(curriculum = nil)
    if curriculum
      user_progress.where(curriculum: curriculum, completed: true).count
    else
      user_progress.where(completed: true).count
    end
  end

  def enrolled_in?(curriculum)
    user_progress.where(curriculum: curriculum).exists?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
