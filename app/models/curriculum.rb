class Curriculum < ApplicationRecord
  belongs_to :tenant
  has_many :chapters, dependent: :destroy
  has_many :user_progress, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :user_highlights, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :order_index, presence: true, uniqueness: { scope: :tenant_id }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:order_index) }

  # Instance methods
  def total_chapters
    chapters.count
  end

  def total_lessons
    chapters.joins(:lessons).count
  end

  def completed_chapters_count(user)
    user.user_progress.where(curriculum: self, completed: true).count
  end

  def completed_lessons_count(user)
    user.lesson_progress.joins(lesson: :chapter).where(chapters: { curriculum: self }, completed: true).count
  end

  def total_chapters_count
    chapters.published.count
  end

  def progress_percentage(user)
    return 0 if total_chapters_count.zero?
    (completed_chapters_count(user).to_f / total_chapters_count * 100).round(2)
  end
end
