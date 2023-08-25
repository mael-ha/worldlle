class InstagramPostJob
  include Sidekiq::Job

  def perform(*_args)
    create_todays_post
    schedule_next_post
  end

  def create_todays_post
    puts 'Starting Instagram Post Job...'
    start = Time.current
    puts '   Fetching headlines...'
    world_summary = WorldSummary.create!
    NewsFetcher.new(world_summary.id).call # unless world_summary.last_country_code.in?(%w[world])
    world_summary = WorldSummary.last
    puts '   Generating world summary...'
    ImageGenerator.new(world_summary.id).call
    puts '   Posting on social media...'
    SocialPoster.new(world_summary.id).call
    finish = Time.current
    diff = finish - start
    puts "Finished in #{diff} seconds."
  end

  def schedule_next_post
    InstagramPostJob.perform_in(1.day)
  end
end
