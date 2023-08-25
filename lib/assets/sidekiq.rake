namespace :sidekiq do
  task clear_queue: :environment do
    Sidekiq::Queue.new('infinity').clear
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
  end
end
