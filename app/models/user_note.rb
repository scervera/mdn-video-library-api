class UserNote < ApplicationRecord
  belongs_to :user
  belongs_to :chapter
  belongs_to :curriculum

  # Validations
  validates :content, presence: true
  validates :user_id, uniqueness: { scope: [:chapter_id, :curriculum_id] }
end
