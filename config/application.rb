require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pong
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_job.queue_adapter = :resque
  end

  def self.telegram_enabled?
    ENV.key?('TELEGRAM_API_KEY') && ENV.key?('TELEGRAM_CHAT_ID')
  end

  def self.retry_max
    return ENV['RETRY_MAX'].to_i || 3
  end
end
