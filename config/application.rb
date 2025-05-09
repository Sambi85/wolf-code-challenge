require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WolfApiChallenge
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.active_job.queue_adapter = :sidekiq
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/lib]
    config.eager_load_paths += %W[#{config.root}/lib #{config.root}/app/lib]
  end
end
