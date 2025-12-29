class JwksController < ApplicationController

  def index
    jwk_content = ENV['EPIC_PUBLIC_JWK_JSON']
if jwk_content.blank?
  # This part runs only if the environment variable is NOT set
  jwk_path = Rails.root.join('config', 'keys', 'epic-public.jwk')
  jwk_content = File.read(jwk_path)
end
jwk = JSON.parse(jwk_content)
render json: { keys: [jwk] }
  end
end
