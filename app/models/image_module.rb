class ImageModule < LessonModule
  # Active Storage associations
  has_many_attached :images
  
  # Image-specific validations
  validates :images, presence: true, unless: :new_record?
  
  # Callbacks to ensure consistency
  after_destroy :cleanup_orphaned_metadata
  
  # Image-specific settings
  def self.default_settings
    {
      layout: 'single', # single, gallery, carousel, grid
      show_captions: true,
      allow_zoom: true,
      autoplay: false,
      autoplay_speed: 3000,
      show_navigation: true,
      image_quality: 'high',
      lazy_loading: true
    }
  end
  
  # Instance methods
  def image_metadata
    settings['images'] || []
  end

  def image_metadata=(value)
    settings['images'] = value
  end

  def image_count
    image_metadata.length
  end
  
  def single_image?
    layout == 'single' || image_count == 1
  end
  
  def gallery?
    layout == 'gallery' && image_count > 1
  end
  
  def carousel?
    layout == 'carousel' && image_count > 1
  end
  
  def grid?
    layout == 'grid' && image_count > 1
  end
  
  def layout
    settings['layout'] || 'single'
  end
  
  def layout=(value)
    settings['layout'] = value
  end
  
  def primary_image
    images.first
  end
  
    def thumbnail_urls
    image_metadata.map { |img| img['thumbnail_url'] || img['url'] }
  end

  def full_size_urls
    image_metadata.map { |img| img['url'] }
  end
  
  # Enhanced methods for Active Storage integration
  def attached_images_with_metadata
    images.map.with_index do |image, index|
      metadata = self.image_metadata[index] || {}
      {
        attachment: image,
        metadata: metadata,
        filename: image.filename.to_s,
        content_type: image.content_type,
        byte_size: image.byte_size,
        url: image.url,
        title: metadata['title'] || image.filename.to_s,
        alt_text: metadata['alt_text'] || image.filename.to_s,
        description: metadata['description'],
        thumbnail_url: metadata['thumbnail_url'] || image.url
      }
    end
  end
  
  def add_image_with_metadata(image, metadata = {})
    # Attach the image
    images.attach(image)
    
    # Add metadata to settings
    image_metadata = {
      'title' => metadata[:title] || image.filename.to_s,
      'alt_text' => metadata[:alt_text] || image.filename.to_s,
      'description' => metadata[:description],
      'url' => image.url,
      'thumbnail_url' => metadata[:thumbnail_url] || image.url,
      'file_size' => image.byte_size,
      'content_type' => image.content_type,
      'created_at' => Time.current.iso8601
    }
    
    add_image(image_metadata)
  end
  
  def remove_image_with_metadata(index)
    # Remove the attachment
    images[index]&.purge
    
    # Remove metadata
    remove_image(index)
  end
  
    def validate_images
    return false if image_metadata.blank?
    
    image_metadata.all? do |image|
      image['url'].present? &&
      image['alt_text'].present? &&
      image['title'].present?
    end
  end

  def add_image(image_data)
    new_images = image_metadata + [image_data]
    update(settings: settings.merge('images' => new_images))
  end

  def remove_image(index)
    new_images = image_metadata.reject.with_index { |_, i| i == index }
    update(settings: settings.merge('images' => new_images))
  end

  def reorder_images(new_order)
    return false unless new_order.is_a?(Array) && new_order.length == image_count
    
    reordered_images = new_order.map { |index| image_metadata[index] }
    update(settings: settings.merge('images' => reordered_images))
  end
  
  # Cleanup orphaned metadata when module is destroyed
  private
  
  def cleanup_orphaned_metadata
    # Active Storage will automatically clean up attachments
    # This method can be used for any additional cleanup if needed
  end
  
  # Class methods
  def self.display_name
    'Image Module'
  end
  
  def self.description
    'Image galleries, carousels, and single images with captions'
  end
end
