# Ensure Active Storage configuration is loaded
Rails.application.config.after_initialize do
  if Rails.application.config.active_storage.service_configurations.nil?
    config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
    Rails.application.config.active_storage.service_configurations = config
  end
  
  # Set URL options for Active Storage
  if Rails.env.development?
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 }
    Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }
    Rails.application.config.active_storage.default_url_options = { host: 'localhost', port: 3000 }
  end
end
