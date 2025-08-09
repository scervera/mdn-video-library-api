class UserHighlight < ApplicationRecord
  belongs_to :user
  belongs_to :chapter
  belongs_to :curriculum

  # Validations
  validates :highlighted_text, presence: true
end
