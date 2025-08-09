class UserProgress < ApplicationRecord
  belongs_to :user
  belongs_to :chapter
  belongs_to :curriculum

  # Validations
  validates :user_id, uniqueness: { scope: [:chapter_id, :curriculum_id] }

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  # Callbacks
  before_save :set_completed_at, if: :completed_changed?

  private

  def set_completed_at
    self.completed_at = completed? ? Time.current : nil
  end
end
