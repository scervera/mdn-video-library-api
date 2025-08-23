class UserProgress < ApplicationRecord
  belongs_to :user
  belongs_to :curriculum
  belongs_to :chapter
  belongs_to :tenant

  validates :user_id, uniqueness: { scope: [:curriculum_id, :chapter_id] }

  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false) }
end
