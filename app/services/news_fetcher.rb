# app/services/news_fetcher.rb

require 'httparty'
require 'news-api'

class NewsFetcher
  
    COUNTRY_CODES = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz",  "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp",  "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt",  "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us",  "ve", "za"]
    
    def initialize(world_summary_id, type: "world")
        @type = type
        @newsapi = News.new(ENV["NEWSAPI_KEY"])
        @date = DateTime.yesterday.to_date.strftime('%Y-%m-%d')
        @top_keywords = []
        @openai = OpenAI::Client.new
        @world_summary = WorldSummary.find(world_summary_id)
    end

    def call
        case @type
        when "world"
            fetch_top_10_world_headlines
        else 
            fetch_headlines_from_all_countries
        end
        @world_summary
    end

    def fetch_top_10_world_headlines
        news = @newsapi.get_top_headlines(sources: 'reuters', from: @date, to: @date, sortBy: "popularity").first(10)
        #news = @newsapi.get_top_headlines(category: 'science', from: @date, to: @date, sortBy: "popularity").first(10)
        news.map! { _1.title }
        keywords = extract_keywords(news).split(", ")
        @world_summary.update!(keywords: @world_summary.keywords + keywords, last_country_code: "world", headlines: news, country_codes: "world")
    end

    def fetch_headlines_from_all_countries
        if @world_summary.country_codes.empty?
            @world_summary.update!(country_codes: ["fr"])
        end 
        @world_summary.country_codes.each do |code|
            next if @world_summary.last_country_code == code
            news = @newsapi.get_top_headlines(country: code, from: @date, to: @date, sortBy: "popularity").first(10)
            news.map! { _1.title }
            keywords = extract_keywords(news)
            keywords = JSON.parse(keywords).split(", ")
            @world_summary.update!(keywords: @world_summary.keywords + keywords, last_country_code: code, headlines: news)
        end
    end

    def extract_keywords(headlines)
        number_of_keywords = 3
        keywords_prompt =  "You are a novel writer. Preparing for you next novel, you get inspiration from international news. Given one headline, you get #{number_of_keywords} keywords out of it. Here is an array of #{headlines.length} headlines: #{headlines}.
        Return one string containing #{headlines.length * number_of_keywords} english keywords, separeted by a coma, representing all of them, that are the most important keywords of the headlines."
        response = @openai.completions(
            parameters: {
                model: "text-davinci-003",
                prompt: keywords_prompt,
                max_tokens: 100,
                temperature: 0.7,
        })
        keywords = response.dig("choices", 0, "text").strip
        keywords
    end
end
