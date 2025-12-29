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

  rescue => e
    Rails.logger.error "Epic FHIR client error: #{e.message}"
    Rails.logger.error "Epic FHIR client backtrace: #{e.backtrace.join("\n")}"
    raise "Epic FHIR request failed: #{e.message}"
  end

  def fetch_patient_observation(patient_id, category)
    puts "Fetching patient observation for patient ID: #{patient_id} and category: #{category}"
    get("Observation?patient=#{patient_id}&category=#{category}")
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

  def fetch_patient_allergies(patient_id)
    puts "Fetching patient allergies for patient ID: #{patient_id}"
    get("AllergyIntolerance?patient=#{patient_id}")
  end

  def fetch_patient_immunizations(patient_id)
    puts "Fetching patient immunizations for patient ID: #{patient_id}"
    get("Immunization?patient=#{patient_id}")
  end

  # 3. Encounter
  def fetch_patient_encounters(patient_id)
    get("Encounter?patient=#{patient_id}&_count=50")
  end

  # 4. Medication Request
  def fetch_patient_medication_requests(patient_id)
    get("MedicationRequest?patient=#{patient_id}")
  end


  def fetch_patient_procedures(patient_id)
    get("Procedure?patient=#{patient_id}")
  end

  def fetch_patient_care_plans(patient_id)
    get("CarePlan?patient=#{patient_id}")
  end

  def fetch_patient_diagnostic_reports(patient_id)
    get("DiagnosticReport?patient=#{patient_id}")
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
