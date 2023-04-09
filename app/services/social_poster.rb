# app/services/social_poster.rb

require 'koala'
require 'open-uri'
require 'twitter'

class SocialPoster
    def initialize(world_summary_id)
        world_summary = WorldSummary.find(world_summary_id)
        @image_url = world_summary.image_url
        access_token = ""
        @user_id = ""
        @graph = Koala::Facebook::API.new(access_token)
        @caption = world_summary.story
        @date = (world_summary.created_at - 1.day).strftime("%d/%m/%Y")
    end

    def call
        download_image
        #post_to_instagram
        post_to_twitter
        delete_image
    end

    def download_image
        image_data = URI.open(@image_url).read
        File.open('tmp/worldlle_tmp.jpg', 'wb') do |file|
            file.write(image_data)
        end
    end

    def post_to_twitter
        # Upload the image to Twitter
        # Post the tweet with the image and prompt as the text
        begin
            tweet = TwitterClient.update_with_media("[#{@date}] - #{@caption}", File.new('tmp/worldlle_tmp.jpg'))
        rescue Twitter::Error => e
            puts "Error posting to Twitter: #{e}"
        end
    end

    def delete_image
        File.delete('tmp/worldlle_tmp.jpg')
    end

  
    def post_to_instagram
    # Upload the image to the Instagram Creator account's media container
    #response = @graph.put_connections(@user_id, "media", image_url: File.expand_path('worldlle_tmp.jpg'), caption: "[#{@date}] - #{@caption}")
    response = @graph.put_connections(@user_id, "media", image_url: @image_url, caption: "[#{@date}] - #{@caption}")

    # Get the resulting media ID
    media_id = response['id']

    # Publish the uploaded media
    graph.put_connections(media_id, "media_publish")

    # Clean up the temporary image file
    File.delete('worldlle_tmp.jpg')
  end
  # ...
end
