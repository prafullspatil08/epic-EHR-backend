require 'rest-client'
require 'json'

class EpicFhirClient
  BASE_URL = 'https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4'

  def initialize(access_token)
    @access_token = access_token
  end

  def get(endpoint)
    url = "#{BASE_URL}/#{endpoint}"
    response = RestClient.get(url, {
      Authorization: "Bearer #{@access_token}",
      Accept: 'application/json'
    })
    JSON.parse(response.body)
  end

  def fetch_observations(patient_id)
    puts "Fetching observations for patient ID: #{patient_id}"
    get("Observation/#{patient_id}")
  end

  def fetch_conditions(patient_id)
    get("Condition/#{patient_id}")
  end

  def post(endpoint, body)
    url = "#{BASE_URL}/#{endpoint}"
    response = RestClient.post(url, body.to_json, {
      Authorization: "Bearer #{@access_token}",
      Accept: 'application/json',
      content_type: :json
    })
    JSON.parse(response.body)
  end
end
