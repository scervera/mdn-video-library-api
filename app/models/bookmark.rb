class Bookmark < ApplicationRecord
  belongs_to :lesson
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :timestamp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: [:lesson_id, :timestamp], message: "already has a bookmark at this timestamp for this lesson" }

  # Scopes
  scope :for_lesson, ->(lesson_id) { where(lesson_id: lesson_id) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :ordered_by_timestamp, -> { order(:timestamp) }

  # Instance methods
  def formatted_timestamp
    # Convert decimal timestamp to MM:SS format
    minutes = (timestamp / 60).floor
    seconds = (timestamp % 60).floor
    sprintf("%02d:%02d", minutes, seconds)
  end

  def formatted_timestamp_with_hours
    # Convert decimal timestamp to HH:MM:SS format
    hours = (timestamp / 3600).floor
    minutes = ((timestamp % 3600) / 60).floor
    seconds = (timestamp % 60).floor
    
    if hours > 0
      sprintf("%02d:%02d:%02d", hours, minutes, seconds)
    else
      sprintf("%02d:%02d", minutes, seconds)
    end
  end

  # Class methods
  def self.create_for_user(user, lesson, attributes)
    create(attributes.merge(user: user, lesson: lesson))
  end

  def self.find_by_user_and_lesson(user, lesson)
    where(user: user, lesson: lesson).ordered_by_timestamp
  end
end
