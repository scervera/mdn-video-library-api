class Bookmark < ApplicationRecord
  belongs_to :lesson
  belongs_to :user
  belongs_to :tenant
  belongs_to :chapter, optional: true

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content_type, inclusion: { in: %w[bookmark clip note] }
  validates :privacy_level, inclusion: { in: %w[private shared public] }
  
  # Custom validations
  validate :validate_time_fields
  validate :validate_tenant_isolation
  validate :validate_unique_bookmark_timestamp, if: -> { content_type == 'bookmark' }

  # Scopes
  scope :bookmarks, -> { where(content_type: 'bookmark') }
  scope :clips, -> { where(content_type: 'clip') }
  scope :notes, -> { where(content_type: 'note') }
  scope :public_content, -> { where(privacy_level: 'public') }
  scope :shared_content, -> { where(privacy_level: 'shared') }
  scope :for_lesson, ->(lesson_id) { where(lesson_id: lesson_id) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :ordered_by_timestamp, -> { order(:timestamp) }

  # Instance methods
  def is_clip?
    content_type == 'clip'
  end

  def is_bookmark?
    content_type == 'bookmark'
  end

  def is_note?
    content_type == 'note'
  end

  def duration
    return nil unless is_clip? && in_sec && out_sec
    out_sec - in_sec
  end

  def can_be_accessed_by?(user)
    return true if user_id == user.id
    return true if privacy_level == 'public' && user.tenant == self.user.tenant
    return true if privacy_level == 'shared' && shared_with&.include?(user.id.to_s)
    false
  end

  def formatted_timestamp
    return nil unless timestamp
    # Convert decimal timestamp to MM:SS format
    minutes = (timestamp / 60).floor
    seconds = (timestamp % 60).floor
    sprintf("%02d:%02d", minutes, seconds)
  end

  def formatted_timestamp_with_hours
    return nil unless timestamp
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

  private

  def validate_time_fields
    case content_type
    when 'bookmark'
      errors.add(:timestamp, 'is required for bookmarks') if timestamp.blank?
    when 'clip'
      errors.add(:in_sec, 'is required for clips') if in_sec.blank?
      errors.add(:out_sec, 'is required for clips') if out_sec.blank?
      if in_sec && out_sec && in_sec >= out_sec
        errors.add(:out_sec, 'must be greater than in_sec')
      end
    when 'note'
      # Notes don't require time fields
    end
  end

  def validate_tenant_isolation
    return unless lesson && user
    unless lesson.tenant == user.tenant
      errors.add(:base, 'Bookmark must be within user tenant')
    end
  end

  def validate_unique_bookmark_timestamp
    existing_bookmark = Bookmark.where(
      user: user,
      lesson: lesson,
      content_type: 'bookmark',
      timestamp: timestamp
    ).where.not(id: id).first
    
    if existing_bookmark
      errors.add(:timestamp, "already has a bookmark at this timestamp for this lesson")
    end
  end
end
