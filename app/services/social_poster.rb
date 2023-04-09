# app/services/social_poster.rb

require 'koala'
require 'open-uri'
require 'twitter'
require 'httparty'
require 'rest-client'

class SocialPoster
    include HTTParty
    BASE_URI = 'https://api.twitter.com/2'

    def initialize(world_summary_id)
        @keywords_only = ENV['KEYWORDS_ONLY'] == 'true'
        @world_summary = WorldSummary.find(world_summary_id)
        @image_url = @world_summary.image_url
        access_token = ""
        @user_id = ""
        @graph = Koala::Facebook::API.new(access_token)
        @image_prompt = @world_summary.image_prompt
        @date = (@world_summary.created_at - 1.day).strftime("%d/%m/%Y")
        @image_path = "tmp/worldlle_tmp.jpg"
        @twitter_bearer_token = ENV['TWITTER_BEARER_TOKEN']
    end

    def call
        download_image
        post_to_instagram
        #post_to_twitter
        #post_to_twitter_v2
        delete_image
    end

    def download_image
        image_data = URI.open(@image_url).read
        File.open(@image_path, 'wb') do |file|
            file.write(image_data)
        end
    end

    def post_to_instagram
      keywords = JSON.parse(@world_summary.keywords).split(", ")
      @caption = if @keywords_only
        "#{@date}. #{keywords} #worldlle"
      else
        "#{@date}. #{@image_prompt} #worldlle"
      end
      InstagramClient.new.post_to_instagram(@caption, @image_url)
    end

    def post_to_twitter
        # Upload the image to Twitter
        # Post the tweet with the image and prompt as the text
        begin
            tweet = TwitterClient.update_with_media("[#{@date}] - #{@caption}", File.new(@image_path))
        rescue Twitter::Error => e
            puts "Error posting to Twitter: #{e}"
        end
    end
  
    def post_to_twitter_v2
      # Upload the media to Twitter
      media_key = upload_media(@image_path)
  
      # Post the tweet with the media
      tweet = create_tweet("[#{@date}] - #{@caption} https://twitter.com/intent/tweet?hashtags=WorldllE", media_key)
    end
  
    def upload_media(file_path)
      url = "https://api.twitter.com/2/media/image"
      file = File.open(file_path)
    
      response = RestClient.post(url, { file: file }, { 'Content-Type' => 'multipart/form-data', 'Authorization' => "Bearer #{@twitter_bearer_token}" })
      file.close
    
      raise "Error uploading media: #{response.body}" unless response.code == 201
    
      json = JSON.parse(response.body)
      json['media_key']
    end
  
    def create_tweet(text, media_key)
      url = "#{BASE_URI}/tweets"
      payload = {
        'status': text,
        'media_keys': [media_key]
      }
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@twitter_bearer_token}"
      }
  
      response = post(url, body: payload.to_json, headers: headers)
  
      raise "Error posting tweet: #{response.body}" unless response.success?
  
      JSON.parse(response.body)
    end

    def delete_image
        File.delete(@image_path)
    end
end
