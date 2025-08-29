class ResourcesModule < LessonModule
  # Active Storage associations
  has_many_attached :files
  
  # Resources-specific validations
  validates :resources, presence: true, unless: :new_record?
  
  # Callbacks to ensure consistency
  after_destroy :cleanup_orphaned_metadata
  
  # Resources-specific settings
  def self.default_settings
    {
      show_download_count: true,
      allow_comments: false,
      group_by_type: true,
      show_file_size: true,
      max_file_size: 50.megabytes
    }
  end
  
  # Instance methods
  def resources
    settings['resources'] || []
  end
  
  def resources=(value)
    settings['resources'] = value
  end
  
  def resource_count
    resources.length
  end
  
  def file_resources
    resources.select { |r| r['type'] == 'file' }
  end
  
  def link_resources
    resources.select { |r| r['type'] == 'link' }
  end
  
  def video_resources
    resources.select { |r| r['type'] == 'video' }
  end
  
  def total_file_size
    file_resources.sum { |r| r['file_size'] || 0 }
  end
  
  def formatted_total_size
    return '0 B' if total_file_size == 0
    
    units = %w[B KB MB GB]
    size = total_file_size.to_f
    unit_index = 0
    
    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end
    
    "#{size.round(1)} #{units[unit_index]}"
  end
  
  # Enhanced methods for Active Storage integration
  def attached_files_with_metadata
    files.map.with_index do |file, index|
      metadata = resources[index] || {}
      {
        attachment: file,
        metadata: metadata,
        filename: file.filename.to_s,
        content_type: file.content_type,
        byte_size: file.byte_size,
        url: file.url,
        title: metadata['title'] || file.filename.to_s,
        description: metadata['description'],
        alt_text: metadata['alt_text']
      }
    end
  end
  
  def remove_file_with_metadata(index)
    # Remove the attachment
    files[index]&.purge
    
    # Remove metadata
    remove_resource(index)
  end
  
  def validate_resources
    return false if resources.blank?
    
    resources.all? do |resource|
      resource['title'].present? &&
      resource['type'].present? &&
      %w[file link video].include?(resource['type']) &&
      (
        (resource['type'] == 'file' && resource['url'].present?) ||
        (resource['type'] == 'link' && resource['url'].present?) ||
        (resource['type'] == 'video' && resource['url'].present?)
      )
    end
  end
  
  def add_resource(resource_data)
    new_resources = resources + [resource_data]
    update(settings: settings.merge('resources' => new_resources))
  end
  
  def remove_resource(index)
    new_resources = resources.reject.with_index { |_, i| i == index }
    update(settings: settings.merge('resources' => new_resources))
  end
  
  def add_file_with_metadata(file, metadata = {})
    # Attach the file
    files.attach(file)
    
    # Get the attached file to access its properties
    attached_file = files.last
    
    # Add metadata to settings
    file_metadata = {
      'type' => 'file',
      'title' => metadata[:title] || attached_file.filename.to_s,
      'description' => metadata[:description],
      'alt_text' => metadata[:alt_text],
      'file_size' => attached_file.byte_size,
      'content_type' => attached_file.content_type,
      'url' => attached_file.url,
      'created_at' => Time.current.iso8601
    }
    
    add_resource(file_metadata)
  end
  
  # Cleanup orphaned metadata when module is destroyed
  private
  
  def cleanup_orphaned_metadata
    # Active Storage will automatically clean up attachments
    # This method can be used for any additional cleanup if needed
  end
  
  # Class methods
  def self.display_name
    'Resources Module'
  end
  
  def self.description
    'Downloadable files, links, and additional resources'
  end
end
