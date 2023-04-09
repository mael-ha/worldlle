# app/services/image_generator.rb

require 'openai'

class ImageGenerator
    SIZE = {
        sm: "256x256",
        md: "512x512",
        lg: "1024x1024",
    }

  def self.generate(prompt)
    OpenAI.api_key = "your_openai_api_key"

    response = OpenAI::Completion.create(
      engine: "davinci-codex",
      prompt: "Create an image description based on the following text: #{prompt}",
      max_tokens: 50,
      n: 1,
      stop: nil,
      temperature: 0.7
    )
    news_summary = response.choices.first.text.strip

    response = OpenAI::Completion.create(
        engine: "davinci-codex",
        prompt: "You are a modern digital artist using AI to express your ideas. Your main tool is Dall·e from OpenAI, your are the world expert using it. Everyday, you create a prompt out of a news summary that generates a beautiful realistic digital art image. Here is the news summary: #{news_summary}. Generate the prompt for dall·e.",
        max_tokens: 50,
        n: 1,
        stop: nil,
        temperature: 0.7
      )
    image_prompt = response.choices.first.text.strip

    response = client.images.generate(parameters: { prompt: image_prompt, size: SIZE[:lg] })
    image_url = response.dig("data", 0, "url")
  end
end
