class LessonModule < ApplicationRecord
  belongs_to :lesson
  
  # STI setup
  self.inheritance_column = 'type'
  
  # Validations
  validates :type, presence: true, inclusion: { 
    in: %w[VideoModule TextModule AssessmentModule ResourcesModule ImageModule] 
  }
  validates :title, presence: true
  validates :position, presence: true, uniqueness: { scope: :lesson_id }
  
  # Scopes
  scope :ordered, -> { order(:position) }
  scope :published, -> { where.not(published_at: nil) }
  scope :by_type, ->(type) { where(type: type) }
  
  # Instance methods
  def published?
    published_at.present?
  end
  
  def publish!
    update!(published_at: Time.current)
  end
  
  def unpublish!
    update!(published_at: nil)
  end
  
  # Class methods for module types
  def self.module_types
    %w[VideoModule TextModule AssessmentModule ResourcesModule ImageModule]
  end
  
  def self.available_types
    module_types.map { |type| [type.constantize.display_name, type] }
  end
end
