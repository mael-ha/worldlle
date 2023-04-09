# app/services/image_generator.rb

require 'openai'

class ImageGenerator
    SIZE = {
        sm: "256x256",
        md: "512x512",
        lg: "1024x1024",
    }

  def initialize(keywords)
    @openai = OpenAI::Client.new
    @keywords = keywords
    @world_summary = WorldSummary.create!(keywords: keywords)
  end

  def call
    generate_world_story
    generate_image_prompt
    generate_image
  end
  
  def generate_world_story
    prompt = "You are a new era very creative writer. Everyday, you imagine a story that reflects the worlds face. To do so, you get inspriation from news from all over the words, you work with a friend that gives you all the most important keywords of the day's worldwide news. I am this friend. Here is a list of all the news headlines keywords of the day : #{@keywords}. Identify the most important keywords there that reflect the world, and create a story of 300 worlds."
    response = client.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt,
            temperature: 0.9,
        })
    @story = response.dig("choices", 0, "text").strip
    @world_summary.udpate!(story: @story)
  end

  def generate_image(prompt)
    gpt_image_prompt = "You are a modern digital artist using AI to express your ideas. You get your inspiration from a story wrote by a friend. I am this friend. Your main tool is Dall·e from OpenAI, your are the world expert using it. Everyday, you create a prompt out of story that I wrote, to generates a beautiful realistic digital art image. Here is today's story: #{@story}. Generate the prompt for dall·e."
    response = @openai.completions(
        engine: "davinci",
        prompt: gpt_image_prompt,
        max_tokens: 100,
        n: 1,
        stop: nil,
        temperature: 0.9
    )
    @image_prompt = response.dig("choices", 0, "text").strip
    @world_summary.udpate!(image_prompt: @image_prompt)
  end

  def generate_image
    response = @openai.images.generate(parameters: { prompt: @image_prompt, size: SIZE[:lg] })
    @image_url = response.dig("data", 0, "url")
    @world_summary.udpate!(image_url: @image_url)
  end
end
