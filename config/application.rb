require_relative "boot"

require "rails/all"
# require_relative "../lib/tenant_middleware"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MdnVideoLibraryApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
  # Configure Active Storage service
  config.active_storage.service = ENV.fetch("RAILS_STORAGE_SERVICE", "local")

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Add tenant middleware (using proper class reference)
    # config.middleware.use TenantMiddleware
    
    # Configure Active Storage URL options
    config.after_initialize do
      ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 }
    end
  end
end
