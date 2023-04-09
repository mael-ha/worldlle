class WorldlleBot
    def call
        top_keywords = NewsFetcher.new.call
        world_summary = ImageGenerator.new(top_keywords).call
        SocialPoster.new(world_summary).call
    end
end
