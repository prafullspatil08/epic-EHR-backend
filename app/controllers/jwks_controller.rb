class JwksController < ApplicationController

  def index
    jwk_path = Rails.root.join("/etc/secrets/epic-public.jwk")
    jwk = JSON.parse(File.read(jwk_path))
    render json: { keys: [jwk] }
  end
end
