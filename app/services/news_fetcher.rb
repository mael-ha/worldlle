# app/services/news_fetcher.rb

require 'httparty'

class NewsFetcher
  def self.fetch_headlines
    api_key = 'your_api_key'
    response = HTTParty.get("https://newsapi.org/v2/top-headlines?language=en&category=world&sortBy=popularity&pageSize=10&apiKey=#{api_key}")
    news_data = JSON.parse(response.body)
    headlines = news_data["articles"].map { |article| article["title"] }
    headlines
  end

  def self.generate_prompt(headlines)
    OpenAI.api_key = "your_openai_api_key"

    prompt = "Create a single sentence that combines the following headlines:\n\n#{headlines.join("\n")}\n\nCombined sentence:"
    response = OpenAI::Completion.create(
      engine: "davinci-codex",
      prompt: prompt,
      max_tokens: 100,
      n: 1,
      stop: nil,
      temperature: 0.7
    )
    combined_sentence = response.choices.first.text.strip
    combined_sentence
  end
end
