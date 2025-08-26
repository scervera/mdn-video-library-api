class TextModule < LessonModule
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
  
  # Class methods
  def self.display_name
    'Text Module'
  end
  
  def self.description
    'Rich text content with Tiptap editor integration'
  end
end
