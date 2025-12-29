class Api::V1::PatientController < ApplicationController
    before_action :set_epic_client
  
    rescue_from StandardError, with: :handle_error
  
    def patient
      patient_id = params[:id]
      data = @client.get("Patient/#{patient_id}")
      render json: data
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
      render json: data
    end
  
    # GET /api/patient-condition
    def fetch_patient_condition
      patient_id = params[:patient]
      data = @client.fetch_patient_condition(patient_id)
      render json: data
    end

    # GET /api/bulk-kick-off?group_id=123
    def bulk_kick_off
      puts "Bulk kick off for group ID: #{params[:group_id]}"
      group_id = params[:group_id]
      data = @client.fetch_bulk_kick_off(group_id)
      render json: { success: true, message: 'Bulk kick off results', data: data }
    end

    def fetch_patient_by_mrn
      mrn = params[:identifier]
      data = @client.fetch_patient_by_mrn(mrn)
      render json: data
    end

    def fetch_patient_allergies
      patient_id = params[:patient]
      data = @client.fetch_patient_allergies(patient_id)
      render json: data
    end

    def fetch_patient_immunizations
      patient_id = params[:patient]
      data = @client.fetch_patient_immunizations(patient_id)
      render json: data
    end

    def fetch_patient_medication_requests
      patient_id = params[:patient]
      data = @client.fetch_patient_medication_requests(patient_id)
      render json: data
    end

    def fetch_patient_encounters
      patient_id = params[:patient]
      data = @client.fetch_patient_encounters(patient_id)
      render json: data
    end

    def fetch_patient_procedures
      patient_id = params[:patient]
      data = @client.fetch_patient_procedures(patient_id)
      render json: data
    end

    def fetch_patient_care_plans
      patient_id = params[:patient]
      data = @client.fetch_patient_care_plans(patient_id)
      render json: data
    end

    def patient_everything
      patient_id = params[:patient]
      data = @client.get("Patient/#{patient_id}/$everything")
      render json: data
    end

    def fetch_patient_diagnostic_reports
      patient_id = params[:patient]
      data = @client.fetch_patient_diagnostic_reports(patient_id)
      render json: data
    end
      
  
    private
  
    def set_epic_client
      token = EpicAuth.get_access_token
      @client = EpicFhirClient.new(token)
    end
  
    def handle_error(exception)
      render json: { success: false, error: exception.message }, status: :ok
    end
  end