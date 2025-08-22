class Api::V1::PatientController < ApplicationController
    before_action :set_epic_client
  
    rescue_from StandardError, with: :handle_error
  
    def patient
      patient_id = params[:id]
      data = @client.get("Patient/#{patient_id}")
      render json: { success: true, message: 'Patient fetched', data: data }
    end
  
    # GET /api/patient-search?family=Smith&gender=male
    def patient_search
      query = request.query_string
      data = @client.get("Patient?#{query}")
      render json: { success: true, message: 'Search results', data: data }
    end
  
    # POST /api/patient-match
    def patient_match
      data = @client.post('Patient/$match', request.request_parameters)
      render json: { success: true, message: 'Match results', data: data }
    end
  
    # GET /api/patient-observation?patient=123&category=lab
    def fetch_patient_observation
      patient_id = params[:patient]
      category = params[:category]
      data = @client.fetch_patient_observation(patient_id, category)
      render json: { success: true, message: 'Observations fetched', data: data }
    end
  
    # GET /api/patient-condition
    def fetch_patient_condition
      patient_id = params[:patient]
      data = @client.fetch_patient_condition(patient_id)
      render json: { success: true, message: 'Condition fetched', data: data }
    end
  
    private
  
    def set_epic_client
      token = EpicAuth.get_access_token
      @client = EpicFhirClient.new(token)
    end
  
    def handle_error(exception)
      render json: { success: false, error: exception.message }, status: :bad_request
    end
  end