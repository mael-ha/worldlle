class WorldlleBot
    def call
        puts "Starting WorldlleBot..."
        start = Time.current
        puts "   Fetching headlines..."
        # world_summary = if WorldSummary.today.any?
        #     WorldSummary.today.first
        # else
        #     WorldSummary.create!
        # end
        world_summary = WorldSummary.create!
        NewsFetcher.new(world_summary.id).call #unless world_summary.last_country_code.in?(%w[world])
        world_summary = WorldSummary.last
        puts "   Generating world summary..."
        ImageGenerator.new(world_summary.id).call
        puts "   Posting on social media..."
        SocialPoster.new(world_summary.id).call
        finish = Time.current
        diff = finish - start
        puts "Finished in #{diff} seconds."
    end
end
