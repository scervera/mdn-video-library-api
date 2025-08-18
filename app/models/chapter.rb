class Chapter < ApplicationRecord
  belongs_to :curriculum
  belongs_to :tenant
  has_many :lessons, dependent: :destroy
  has_many :user_progress, dependent: :destroy

  validates :title, presence: true
  validates :order_index, presence: true, uniqueness: { scope: :curriculum_id }

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:order_index) }

  def total_lessons
    lessons.count
  end

  def completed_lessons_count(user)
    user.lesson_progress.joins(:lesson).where(lessons: { chapter: self }, completed: true).count
  end

  def total_lessons_count
    lessons.published.count
  end

  def progress_percentage(user)
    return 0 if total_lessons_count.zero?
    (completed_lessons_count(user).to_f / total_lessons_count * 100).round(2)
  end
end
