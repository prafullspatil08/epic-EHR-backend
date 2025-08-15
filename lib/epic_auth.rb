require 'jwt'
require 'rest-client'
require 'securerandom'
require 'openssl'
require 'json'

class EpicAuth
  TOKEN_URL = 'https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token'
  CLIENT_ID = ENV['EPIC_CLIENT_ID']
  ISSUER = ENV['ISSUER']
  PRIVATE_KEY_PATH = ENV['PRIVATE_KEY_PATH']

  def self.get_access_token
    private_key = OpenSSL::PKey::RSA.new(File.read(PRIVATE_KEY_PATH))
    payload = {
      iss: ISSUER,
      sub: CLIENT_ID,
      aud: TOKEN_URL,
      exp: Time.now.to_i + 300,
      jti: SecureRandom.hex(16)
    }
    jwt_token = JWT.encode(payload, private_key, 'RS384')
    response = RestClient.post(TOKEN_URL, {
      grant_type: 'client_credentials',
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: jwt_token
    })
    JSON.parse(response.body)['access_token']
  end
end
