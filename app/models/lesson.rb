class Lesson < ApplicationRecord
  belongs_to :chapter
  has_many :lesson_progress, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: %w[video text image pdf] }
  validates :order_index, presence: true, uniqueness: { scope: :chapter_id }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:order_index) }

  # Instance methods
  def media_url
    # This would be implemented based on your file storage solution
    # For now, returning the stored media_url
    read_attribute(:media_url)
  end
end
