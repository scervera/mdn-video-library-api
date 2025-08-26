class Lesson < ApplicationRecord
  belongs_to :chapter
  belongs_to :tenant
  has_many :lesson_progress, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :lesson_modules, -> { order(:position) }, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :order_index, presence: true, uniqueness: { scope: :chapter_id }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:order_index) }

  # Instance methods
  def module_count
    lesson_modules.count
  end
  
  def has_video_modules?
    lesson_modules.by_type('VideoModule').exists?
  end
  
  def has_text_modules?
    lesson_modules.by_type('TextModule').exists?
  end
  
  def has_assessment_modules?
    lesson_modules.by_type('AssessmentModule').exists?
  end
  
  def video_modules
    lesson_modules.by_type('VideoModule')
  end
  
  def text_modules
    lesson_modules.by_type('TextModule')
  end
  
  def assessment_modules
    lesson_modules.by_type('AssessmentModule')
  end
  
  def resources_modules
    lesson_modules.by_type('ResourcesModule')
  end
  
  def image_modules
    lesson_modules.by_type('ImageModule')
  end
  
  def add_module(module_type, attributes = {})
    next_position = lesson_modules.maximum(:position) || 0
    lesson_modules.create!(
      type: module_type,
      position: next_position + 1,
      **attributes
    )
  end
  
  def reorder_modules(module_ids)
    module_ids.each_with_index do |module_id, index|
      lesson_modules.find(module_id).update!(position: index + 1)
    end
  end
end
