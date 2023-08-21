require 'httparty'

class InstagramClient
  include HTTParty
  BASE_URI = 'https://graph.facebook.com/v16.0'

  def initialize
    @instagram_id = 785_252_483_152_964
    @access_token = ENV['LONG_GRAPH_API_ACCESS_TOKEN'].blank? ? ENV['TEMP_GRAPH_API_ACCESS_TOKEN'] : ENV['LONG_GRAPH_API_ACCESS_TOKEN']
    @user_id = ENV['INSTAGRAM_BUSINESS_ID']
  end

  def post_to_instagram(caption, image_url)
    @caption = caption
    @image_url = image_url
    @container_id = create_container
    publish_media
  rescue StandardError => e
  end

  def get_auth
    url = 'https://api.instagram.com/oauth/authorize'
    body = {
      client_id: @instagram_id,
      rredirect_uri: 'https://worldlle.com/auth/',
      scope: 'user_profile,user_media',
      response_type: 'code'
    }
    response = HTTParty.get(url, query: body)
    puts response
  end

  def refresh_access_token
    url = "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=#{@access_token}"
    body = {
      grand_type: 'ig_refresh_token',
      access_token: @access_token
    }
    response = HTTParty.get(url)
  end

  def get_long_lived_user_access_token(temporary_token = ENV['LONG_GRAPH_API_ACCESS_TOKEN'])
    url = "#{BASE_URI}/oauth/access_token"
    query = {
      grant_type: 'fb_exchange_token',
      client_id: @instagram_id,
      client_secret: ENV['APP_SECRET'], # Make sure to set this in your environment variables
      fb_exchange_token: temporary_token
    }
    response = HTTParty.get(url, query:)

    raise "Failed to exchange temporary token: #{response['error']['message']}" unless response.code == 200

    @access_token = response['access_token']
    @duration = response['expires_in'].to_i
    @expires_at = Time.now + @duration.seconds
    token = {
      access_token: @access_token,
      duration: @duration,
      expires_at: @expires_at
    }
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
        access_token: @access_token,
        caption: @caption
      }
    )
    response['id']
  end

  def publish_media
    response = HTTParty.post(
      "#{BASE_URI}/#{@user_id}/media_publish",
      query: {
        creation_id: @container_id,
        access_token: @access_token
      }
    )
    puts "Request body sent to Instagram API: #{response.request}"
    response['id']
  end
end
