module Api
  module V1
    class ChatController < ApplicationController
      def ask
        prompt = build_clinical_prompt(chat_params)

        if prompt.blank?
          render json: { success: false, error: 'No clinical data provided to generate a summary.' }, status: :ok
          return
        end

        answer = OpenaiService.new(prompt).call

        if answer
          render json: { answer: answer }, status: :ok
        else
          render json: { error: 'Failed to get an answer from the AI service' }, status: :internal_server_error
        end
      end

      private

      def build_clinical_prompt(data)
        return nil unless data.present? && data['patient'].present?

        patient_info = extract_patient_info(data['patient'])
        conditions = extract_conditions(data['conditions'])
        observations = extract_observations(data['observations'])
        allergies = extract_allergies(data['allergies'])

        prompt_parts = ["Summarize the following patient's clinical information for a clinician in bullet points.\n"]
        prompt_parts << patient_info if patient_info.present?
        prompt_parts << "\nConditions:\n#{conditions.join("\n")}" if conditions.present?
        prompt_parts << "\nObservations:\n#{observations.join("\n")}" if observations.present?
        prompt_parts << "\nAllergies:\n#{allergies.join("\n")}" if allergies.present?

        return nil if prompt_parts.size <= 1

        prompt_parts << "\n\nGenerate a brief, clinically relevant summary in natural language. Based on this summary, provide a list of action items for the patient to help them manage their health."
        prompt_parts.join
      end

      def extract_patient_info(patient_data)
        name = patient_data.dig('name', 0, 'text')
        gender = patient_data['gender']
        birth_date = patient_data['birthDate']
        age = birth_date.present? ? ((Time.zone.now - Date.parse(birth_date).to_time) / 1.year.seconds).floor : 'N/A'

        race_ext = patient_data['extension'].find { |ext| ext['url'] == 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race' }
        race = race_ext.dig('extension', 0, 'valueCoding', 'display') if race_ext

        ethnicity_ext = patient_data['extension'].find { |ext| ext['url'] == 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity' }
        ethnicity = ethnicity_ext.dig('extension', 0, 'valueString') if ethnicity_ext

        marital_status = patient_data.dig('maritalStatus', 'text')

        [
          "Patient: #{name}",
          "Age: #{age}",
          "Gender: #{gender}",
          "Race: #{race || 'N/A'}",
          "Ethnicity: #{ethnicity || 'N/A'}",
          "Marital Status: #{marital_status || 'N/A'}"
        ].join("\n")
      end

      def extract_conditions(conditions_data)
        return [] unless conditions_data.present?
        conditions_data.filter_map do |c|
          next unless c['resourceType'] == 'Condition'
          condition_text = c.dig('code', 'text')
          onset = c['onsetDateTime']
          "- #{condition_text} (since #{onset})"
        end
      end

      def extract_observations(observations_data)
        return [] unless observations_data.present?
        # This can be expanded to handle observations when they are available
        []
      end

      def extract_allergies(allergies_data)
        return [] unless allergies_data.present?

        allergies_data.filter_map do |a|
          next unless a['resourceType'] == 'AllergyIntolerance'

          allergy_text = a.dig('code', 'text')
          onset = a['onsetDateTime']
          clinical_status = a.dig('clinicalStatus', 'coding', 0, 'code')
          verification_status = a.dig('verificationStatus', 'coding', 0, 'code')

          details = ["since #{onset}" ]
          details << "clinical status: #{clinical_status}" if clinical_status.present?
          details << "verification status: #{verification_status}" if verification_status.present?

          "- #{allergy_text} (#{details.join(', ')})"
        end
      end

      def chat_params
        params.permit!
      end
    end
  end
end
