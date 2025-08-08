class UserHighlight < ApplicationRecord
  belongs_to :user
  belongs_to :chapter

  # Validations
  validates :highlighted_text, presence: true
end
