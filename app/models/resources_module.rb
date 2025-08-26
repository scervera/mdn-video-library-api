class ResourcesModule < LessonModule
  # Resources-specific validations
  validates :resources, presence: true
  
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
  
  # Class methods
  def self.display_name
    'Resources Module'
  end
  
  def self.description
    'Downloadable files, links, and additional resources'
  end
end
