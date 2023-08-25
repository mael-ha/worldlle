require 'sidekiq'

REDIS_URL = Rails.env.production? ? ENV['REDIS_URL'] : 'redis://localhost:6379/1'

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL }
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL }
end
