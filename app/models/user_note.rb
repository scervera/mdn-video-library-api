class UserNote < ApplicationRecord
  belongs_to :user
  belongs_to :chapter

  # Validations
  validates :content, presence: true
  validates :user_id, uniqueness: { scope: :chapter_id }
end
