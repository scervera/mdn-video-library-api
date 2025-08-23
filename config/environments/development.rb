require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the interest of performance, files that change will be automatically cached.
  # To reset the cache, run `bin/rails tmp:clear`.
  config.cache_classes = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Highlight code that yielded to the console in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allow subdomain hosts for multitenant testing
  config.hosts << "acme1.localhost"
  config.hosts << "acme2.localhost"
  config.hosts << "acme3.localhost"
  config.hosts << "*.localhost"
  config.hosts << "acme1.curriculum-library-api.cerveras.com"
  config.hosts << "acme2.curriculum-library-api.cerveras.com"
  config.hosts << "acme3.curriculum-library-api.cerveras.com"
  config.hosts << "*.curriculum-library-api.cerveras.com"

  # Email configuration for development using Brevo SMTP
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp-relay.brevo.com',
    port: 587,
    domain: 'localhost',
    user_name: ENV['BREVO_SMTP_USERNAME'],
    password: ENV['BREVO_SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
end
