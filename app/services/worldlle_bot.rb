class WorldlleBot
    def call
        puts "Starting WorldlleBot..."
        start = DateTime.now
        puts "   Fetching headlines..."
        world_summary = if WorldSummary.today.any?
            WorldSummary.today.first
        else
            WorldSummary.create!
        end
        NewsFetcher.new(world_summary.id).call unless world_summary.last_country_code.in?(%w[za world])
        puts "   Generating world summary..."
        ImageGenerator.new(world_summary.id).call
        puts "   Posting on social media..."
        SocialPoster.new(world_summary.id).call
        finish = DateTime.now
        puts "Finished in #{finish - start} seconds."
    end
end
