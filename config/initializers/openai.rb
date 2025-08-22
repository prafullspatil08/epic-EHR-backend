OpenAI.configure do |config|
  config.access_token = ENV.fetch("PERPLEXICITY_KEY", nil)
  config.uri_base = "https://api.perplexity.ai/"
end
