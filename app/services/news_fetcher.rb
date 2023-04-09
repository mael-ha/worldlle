# app/services/news_fetcher.rb

require 'httparty'
require 'news-api'

class NewsFetcher
  
    COUNTRY_CODES = [  "ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz",  "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp",  "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt",  "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us",  "ve", "za"]
    
    def initialize
        @newsapi = News.new(ENV["NEWSAPI_KEY"])
        @date = DateTime.yesterday.to_date.strftime('%Y-%m-%d')
        @top_keywords = []
    end

    def call
        fetch_headlines
    end

    def fetch_headlines
        COUNTRY_CODES.each do |code|
            news = newsapi.get_top_headlines(country: code, from: date, to: date, sortBy: "popularity").first(3)
            headlines << news.first.title
            keywords = extract_keywords(headlines)
            @top_keywords += keywords
        end
        @top_keywords
    end

    def extract_keywords(headlines)
        keywords_prompt =  "You are a novel writer. Preparing for you next novel, you get inspiration from international news. Given headlines, you get 3 keywords (in english) out of each of them. Here is an array of 3 headlines: #{headlines}.
        Return an array of 9 keywords representing all of them (3 words for each headline)"
        response = client.completions(
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
