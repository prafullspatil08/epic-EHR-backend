require 'httparty'

class OpenaiService
  def initialize(question)
    @question = question
  end

  def call
    api_key = ENV['PERPLEXICITY_KEY']
    raise 'PERPLEXICITY_KEY is not set' unless api_key

    headers = {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }

    body = {
      model: "sonar",
      messages: [{ role: "user", content: @question }]
    }.to_json

    response = HTTParty.post(
      "https://api.perplexity.ai/chat/completions",
      headers: headers,
      body: body
    )

    if response.success?
      response.parsed_response.dig("choices", 0, "message", "content")
    else
      Rails.logger.error "Perplexity API error: #{response.code} #{response.message}"
      Rails.logger.error "Response body: #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "An unexpected error occurred: #{e.message}"
    nil
  end
end
