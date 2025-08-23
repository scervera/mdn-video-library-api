class UserNote < ApplicationRecord
  belongs_to :user
  belongs_to :chapter, optional: true
  belongs_to :lesson, optional: true
  belongs_to :curriculum
  belongs_to :tenant

  # Validations
  validates :content, presence: true
  validates :user_id, uniqueness: { scope: [:chapter_id, :curriculum_id] }, if: -> { chapter_id.present? }
  validates :user_id, uniqueness: { scope: [:lesson_id] }, if: -> { lesson_id.present? }
  
  # Ensure either chapter_id or lesson_id is present, but not both
  validate :either_chapter_or_lesson_present
  validate :not_both_chapter_and_lesson

  scope :for_chapter, ->(chapter_id) { where(chapter_id: chapter_id) }
  scope :for_lesson, ->(lesson_id) { where(lesson_id: lesson_id) }
  scope :for_curriculum, ->(curriculum_id) { where(curriculum_id: curriculum_id) }
  scope :ordered_by_created, -> { order(created_at: :desc) }

  private

  def either_chapter_or_lesson_present
    if chapter_id.blank? && lesson_id.blank?
      errors.add(:base, "Either chapter_id or lesson_id must be present")
    end
  end

  def not_both_chapter_and_lesson
    if chapter_id.present? && lesson_id.present?
      errors.add(:base, "Cannot have both chapter_id and lesson_id")
    end
  end
end
