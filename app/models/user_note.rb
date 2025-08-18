class UserNote < ApplicationRecord
  belongs_to :user
  belongs_to :chapter
  belongs_to :curriculum
  belongs_to :tenant

  # Validations
  validates :content, presence: true
  validates :user_id, uniqueness: { scope: [:chapter_id, :curriculum_id] }

  scope :for_chapter, ->(chapter_id) { where(chapter_id: chapter_id) }
  scope :for_curriculum, ->(curriculum_id) { where(curriculum_id: curriculum_id) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
end
