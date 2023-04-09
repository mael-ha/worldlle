require 'httparty'

class InstagramClient
  include HTTParty
  BASE_URI = 'https://graph.facebook.com/v16.0'

  def initialize
    @access_token = ENV['GRAPH_API_ACCESS_TOKEN']
    @user_id = ENV['INSTAGRAM_BUSINESS_ID']
  end

  def post_to_instagram(caption, image_url)
    @caption = caption
    @image_url = image_url
    @container_id = create_container
    publish_media
  rescue StandardError => e
    debugger
  end

  private

  def get_user_id
    response = HTTParty.get(
      "#{BASE_URI}/me",
      query: {
        fields: 'instagram_business_account',
        access_token: @access_token
      }
    )
    response['instagram_business_account']['id']
  end

  def create_container
    response = HTTParty.post(
      "#{BASE_URI}/#{@user_id}/media",
      query: {
        image_url: @image_url,
        access_token: @@access_token
      }
    )
    response['id']
  end

  def publish_media
    response = HTTParty.post(
      "#{BASE_URI}/#{@user_id}/media_publish",
      query: {
        creation_id: @container_id,
        caption: @caption,
        access_token: @access_token
      }
    )

    response['id']
  end
end
