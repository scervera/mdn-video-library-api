class ImageModule < LessonModule
  # Active Storage associations
  has_many_attached :images
  
  # Image-specific validations
  validates :images, presence: true
  
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
  def images
    settings['images'] || []
  end
  
  def images=(value)
    settings['images'] = value
  end
  
  def image_count
    images.length
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
    images.map { |img| img['thumbnail_url'] || img['url'] }
  end
  
  def full_size_urls
    images.map { |img| img['url'] }
  end
  
  def validate_images
    return false if images.blank?
    
    images.all? do |image|
      image['url'].present? &&
      image['alt_text'].present? &&
      image['title'].present?
    end
  end
  
  def add_image(image_data)
    new_images = images + [image_data]
    update(settings: settings.merge('images' => new_images))
  end
  
  def remove_image(index)
    new_images = images.reject.with_index { |_, i| i == index }
    update(settings: settings.merge('images' => new_images))
  end
  
  def reorder_images(new_order)
    return false unless new_order.is_a?(Array) && new_order.length == image_count
    
    reordered_images = new_order.map { |index| images[index] }
    update(settings: settings.merge('images' => reordered_images))
  end
  
  # Class methods
  def self.display_name
    'Image Module'
  end
  
  def self.description
    'Image galleries, carousels, and single images with captions'
  end
end
