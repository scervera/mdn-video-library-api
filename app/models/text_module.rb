class TextModule < LessonModule
  # Active Storage attachments for embedded images
  has_many_attached :images
  
  # Text-specific validations
  validates :content, presence: true
  
  # Text-specific settings
  def self.default_settings
    {
      show_toc: true,
      allow_comments: false,
      tiptap_config: {
        extensions: ['heading', 'bold', 'italic', 'link', 'list', 'code', 'blockquote'],
        placeholder: 'Start writing your content...',
        editable: true
      },
      reading_time: true,
      word_count: true
    }
  end
  
  # Instance methods
  def tiptap_content
    content || ''
  end
  
  def word_count
    return 0 if content.blank?
    content.gsub(/<[^>]*>/, '').split(/\s+/).count
  end
  
  def reading_time
    return 0 if content.blank?
    # Average reading speed: 200-250 words per minute
    (word_count / 225.0).ceil
  end
  
  def table_of_contents
    return [] if content.blank?
    
    # Extract headings from Tiptap content
    headings = []
    content.scan(/<h([1-6])[^>]*>(.*?)<\/h[1-6]>/).each_with_index do |match, index|
      level = match[0].to_i
      text = match[1].gsub(/<[^>]*>/, '').strip
      headings << {
        id: "heading-#{index + 1}",
        level: level,
        text: text,
        index: index + 1
      }
    end
    headings
  end
  
  def plain_text_content
    return '' if content.blank?
    content.gsub(/<[^>]*>/, '').strip
  end
  
  def excerpt(length = 150)
    text = plain_text_content
    return text if text.length <= length
    text[0...length].strip + '...'
  end
  
  # Image attachment methods for embedded images in text content
  def attached_images_with_metadata
    # Set URL options for Active Storage
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 } if Rails.env.development?
    
    images.map.with_index do |image, index|
      {
        attachment: image,
        metadata: {},
        filename: image.filename.to_s,
        content_type: image.content_type,
        byte_size: image.byte_size,
        url: image.url,
        title: image.filename.to_s,
        alt_text: image.filename.to_s,
        description: nil,
        thumbnail_url: image.url
      }
    end
  end
  
  def add_image_with_metadata(image, metadata = {})
    # Attach the image
    images.attach(image)
    
    # Get the attached file to access its properties
    attached_file = images.last
    
    # Set URL options for Active Storage
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 } if Rails.env.development?
    
    # Return the image data for the response
    {
      attachment: attached_file,
      metadata: metadata,
      filename: attached_file.filename.to_s,
      content_type: attached_file.content_type,
      byte_size: attached_file.byte_size,
      url: attached_file.url,
      title: metadata[:title] || attached_file.filename.to_s,
      alt_text: metadata[:alt_text] || attached_file.filename.to_s,
      description: metadata[:description],
      thumbnail_url: metadata[:thumbnail_url] || attached_file.url
    }
  end
  
  def remove_image_with_metadata(index)
    # Remove the attachment
    images[index]&.purge
  end
  
  # Class methods
  def self.display_name
    'Text Module'
  end
  
  def self.description
    'Rich text content with Tiptap editor integration'
  end
end
