require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    I18n.available_locales = %i[en ta]

    language = ENV['web_language']
    if language.present? && language == "tamil"
      config.i18n.default_locale = :ta
    else
      config.i18n.default_locale = :en
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:5173'
        # origins '*'

        resource '/api/*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end
  end
end
