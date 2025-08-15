class Api::EpicController < ApplicationController
  # GET /api/patient?id=<PATIENT_ID>
  def test
    render json: { success: true, message: 'Test successful' }
  end
  
  def patient
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    patient_id = params[:id]
    data = client.get("Patient/#{patient_id}")
    render json: { success: true, message: 'Patient fetched', data: data }
  rescue => e
    render json: { success: false, error: e.message }, status: :bad_request
  end

  # GET /api/patient-search?family=Smith&gender=male
  def patient_search
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    query = request.query_string
    data = client.get("Patient?#{query}")
    render json: { success: true, message: 'Search results', data: data }
  rescue => e
    render json: { success: false, error: e.message }, status: :bad_request
  end

  # POST /api/patient-match
  def patient_match
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    data = client.post('Patient/$match', request.request_parameters)
    render json: { success: true, message: 'Match results', data: data }
  rescue => e
    render json: { success: false, error: e.message }, status: :bad_request
  end

  # GET /api/observations?patient_id=123
  def observations
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    patient_id = params[:patient_id]
    data = client.fetch_observations(patient_id)
    render json: { success: true, message: 'Observations fetched', data: data }
  rescue => e
    render json: { success: false, error: e.message }, status: :bad_request
  end

   # GET /api/conditions?patient_id=123
   def conditions
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    patient_id = params[:patient_id]
    data = client.fetch_conditions(patient_id)
    render json: { success: true, message: 'Conditions fetched', data: data }
  rescue => e
    render json: { success: false, error: e.message }, status: :bad_request
  end

  # Other endpoints (bulk-export, bulk-status, bulk-download, appointments, observation) follow similar structure
end
