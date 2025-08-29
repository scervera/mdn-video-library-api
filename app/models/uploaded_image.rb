class UploadedImage < ApplicationRecord
  has_one_attached :file
  
  belongs_to :user
  belongs_to :lesson, optional: true
  belongs_to :lesson_module, optional: true
  
  validates :file, presence: true
  validate :acceptable_file_type
  validate :acceptable_file_size
  
  def url
    if file.attached?
      # Set URL options for Active Storage
      ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 } if Rails.env.development?
      Rails.application.routes.url_helpers.rails_blob_url(file, host: 'localhost', port: 3000)
    end
  end
  
  def filename
    file.filename.to_s if file.attached?
  end
  
  def content_type
    file.content_type if file.attached?
  end
  
  def byte_size
    file.byte_size if file.attached?
  end
  
  private
  
  def acceptable_file_type
    return unless file.attached?
    
    unless file.content_type.in?(['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'])
      errors.add(:file, 'must be a JPEG, PNG, GIF, WebP, or SVG image')
    end
  end
  
  def acceptable_file_size
    return unless file.attached?
    
    unless file.byte_size <= 10.megabytes
      errors.add(:file, 'size must be less than 10MB')
    end
  end
end
