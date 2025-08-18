class UserHighlight < ApplicationRecord
  belongs_to :user
  belongs_to :chapter
  belongs_to :curriculum
  belongs_to :tenant

  validates :highlighted_text, presence: true

  scope :for_chapter, ->(chapter_id) { where(chapter_id: chapter_id) }
  scope :for_curriculum, ->(curriculum_id) { where(curriculum_id: curriculum_id) }
  scope :ordered_by_created, -> { order(created_at: :desc) }
end
