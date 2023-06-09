# app/services/image_generator.rb

require 'openai'

class ImageGenerator
    SIZE = {
        sm: "256x256",
        md: "512x512",
        lg: "1024x1024",
    }

  def initialize(world_summary_id)
    @keywords_only = ENV['KEYWORDS_ONLY'] == 'true'
    @openai = OpenAI::Client.new
    @world_summary = WorldSummary.find(world_summary_id)
    @keywords = @world_summary.keywords
    @keywords_stringified = @keywords.join(", ")
  end

  def call
    while @world_summary.reload.image_url.nil?
      generate_world_story
      generate_image_prompt
      generate_image
      @world_summary.increment!(:try_count)
      break if @world_summary.try_count > 10
    end
  end
  
  def generate_world_story
    #return if @world_summary.story.present?
    prompt_headlines = "You are a new era very creative writer. Everyday, you imagine a story that reflects the worlds face. To do so, you get inspriation from news from all over the words, you work with a friend that gives you all the 10 most important headlines of the day's worldwide news. I am this friend. Here is a list of all the headlines of the day : #{@headlines}. Create a story of 300 words reflecting the world's face."
    prompt_keywords = "You are a new era very creative writer. Everyday, you imagine a story that reflects the worlds face. To do so, you get inspriation from news from all over the words, you work with a friend that gives you all the most important keywords of the day's worldwide news. I am this friend. Here is a list of all the news headlines keywords of the day : #{@keywords}. Identify the most important keywords there that reflect the world, and create a story of 300 words."
    prompt_science = "You are a new era very positive and creative writer. Everyday, you imagine a story that reflects the worlds face through it's scientific news. To do so, you get inspriation from scientific news from all over the words, you work with a friend that gives you all the 10 most important headlines of the day's worldwide scientific news. I am this friend. Here is a list of all the headlines of the day : #{@headlines}. Create a story of 300 words reflecting today's world's face."
    response = @openai.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt_headlines,
            temperature: 0.7,
            max_tokens: 500,
        })
    @story = response.dig("choices", 0, "text").strip
    @world_summary.update!(story: @story)
  end

  def generate_image_prompt
    #return if @world_summary.image_prompt.present?

    prompt = "You are a modern digital artist using AI to express your ideas. You love to imagine a detailed scene from a story. You get your inspiration from a story wrote by a friend. I am this friend. You always describe scenes so we see it as realistic digital art. Here is today's story: #{@story}. Depict an ultra realistic scene based on today's story, with a maximum of 260 characters. Describe the scene as if you were there. Be very descriptive about what you see, give a lot of details. Give context of the image, if its a painting, a 3D, a photo, with lot of details. Add adjectives to make sure it is ultra realistic."
    response = @openai.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt,
            temperature: 0.7,
            max_tokens: 500,
        })
    @image_prompt = response.dig("choices", 0, "text").strip
    @world_summary.update!(image_prompt: @image_prompt)
  end

  def generate_image
    return if @world_summary.image_url.present?
    
    prompt = @keywords_only ? "This is the world today: #{@keywords_stringified}" : @world_summary.image_prompt
    response = @openai.images.generate(parameters: { prompt: prompt, size: SIZE[:lg] })
    @image_url = response.dig("data", 0, "url")
    @world_summary.update!(image_url: @image_url)
  end
end
