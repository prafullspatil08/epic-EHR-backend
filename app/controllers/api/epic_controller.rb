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

  # GET /api/bulk-file-request?bulk_id=123&output_id=456
  def bulk_file_request
    token = EpicAuth.get_access_token
    client = EpicFhirClient.new(token)
    bulk_id = params[:bulk_id];
    output_id = params[:output_id]
    data = client.fetch_bulk_file_request(bulk_id,output_id)
    render json: { success: true, message: 'Match results', data: data }
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
