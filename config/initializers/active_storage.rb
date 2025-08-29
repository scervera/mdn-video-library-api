# Ensure Active Storage configuration is loaded
Rails.application.config.after_initialize do
  if Rails.application.config.active_storage.service_configurations.nil?
    config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
    Rails.application.config.active_storage.service_configurations = config
  end
end
