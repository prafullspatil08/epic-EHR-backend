require 'jwt'
require 'rest-client'
require 'securerandom'
require 'json'
require 'base64'
require 'openssl'

class EpicAuth
  TOKEN_URL = ENV['EPIC_TOKEN_URL']
  CLIENT_ID = ENV['EPIC_CLIENT_ID']
  PRIVATE_JWK_PATH = Rails.root.join("config/keys/epic-private.jwk")

  def self.rsa_key_from_jwk(jwk)
    n  = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["n"]), 2)
    e  = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["e"]), 2)
    d  = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["d"]), 2)
    p  = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["p"]), 2)
    q  = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["q"]), 2)
    dp = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["dp"]), 2)
    dq = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["dq"]), 2)
    qi = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk["qi"]), 2)

    seq = OpenSSL::ASN1::Sequence([
      OpenSSL::ASN1::Integer(0), # version
      OpenSSL::ASN1::Integer(n),
      OpenSSL::ASN1::Integer(e),
      OpenSSL::ASN1::Integer(d),
      OpenSSL::ASN1::Integer(p),
      OpenSSL::ASN1::Integer(q),
      OpenSSL::ASN1::Integer(dp),
      OpenSSL::ASN1::Integer(dq),
      OpenSSL::ASN1::Integer(qi)
    ])

    OpenSSL::PKey::RSA.new(seq.to_der)
  end

  def self.get_access_token
    jwk_data = JSON.parse(File.read(PRIVATE_JWK_PATH))
    rsa_private_key = rsa_key_from_jwk(jwk_data)

    payload = {
      iss: CLIENT_ID,
      sub: CLIENT_ID,
      aud: TOKEN_URL,
      exp: 5.minutes.from_now.to_i,
      jti: SecureRandom.uuid
    }

    jwt_token = JWT.encode(
      payload,
      rsa_private_key,
      "RS384",
      kid: jwk_data["kid"]
    )

    response = RestClient.post(
      TOKEN_URL,
      {
        grant_type: "client_credentials",
        client_id: CLIENT_ID,
        client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        client_assertion: jwt_token,
        scope: ENV["EPIC_SCOPES"]
      }
    )

    JSON.parse(response.body)["access_token"]
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Epic token error #{e.http_code}: #{e.response}"
      raise "Epic token request failed: #{e.response}"
  end
end
