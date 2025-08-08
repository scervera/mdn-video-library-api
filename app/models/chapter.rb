class Chapter < ApplicationRecord
  # Associations
  has_many :lessons, dependent: :destroy
  has_many :user_progress, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :order_index, presence: true, uniqueness: true

  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:order_index) }

  # Instance methods
  def total_lessons
    lessons.count
  end

  def completed_lessons_count(user)
    user.lesson_progress.joins(:lesson).where(lessons: { chapter: self }, completed: true).count
  end
end
