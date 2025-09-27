require 'rest-client'
require 'json'

class EpicFhirClient
  BASE_URL = 'https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4'

  def initialize(access_token)
    @access_token = access_token
  end

  def get(endpoint)
    url = "#{BASE_URL}/#{endpoint}"
    puts "Fetching data for endpoint: #{url}"
    response = RestClient.get(url, {
      Authorization: "Bearer #{@access_token}",
      Accept: 'application/fhir+json',
      Prefer: 'respond-async'
    })
    puts "Response: #{response}"
    JSON.parse(response.body)
  end

  def fetch_patient_observation(patient_id, category)
    puts "Fetching patient observation for patient ID: #{patient_id} and category: #{category}"
    get("Observation?patient=#{patient_id}")
  end

  def fetch_patient_condition(patient_id)
    puts "Fetching patient condition for patient ID: #{patient_id}"
    get("Condition?patient=#{patient_id}")
  end

  def fetch_patient_by_mrn(mrn)
    get("Patient?identifier=MRN|#{mrn}")
  end

  def fetch_observations(patient_id)
    puts "Fetching observations for patient ID: #{patient_id}"
    get("Observation/#{patient_id}")
  end

  def fetch_bulk_file_request(bulk_file_id,output_id)
    puts "Fetching bulk file request for bulk file ID: #{bulk_file_id} and output ID: #{output_id}"
    get("BulkRequest/#{bulk_file_id}/#{output_id}")
  end

  def fetch_bulk_kick_off(group_id)
    puts "Fetching bulk file request for bulk file ID: #{group_id} and output ID: #{group_id}"
    get("Group/#{group_id}/$export")
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
