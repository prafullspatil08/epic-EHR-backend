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

      def build_clinical_prompt(fhir_bundle)
        return nil unless fhir_bundle.present? && fhir_bundle['resourceType'] == 'Bundle' && fhir_bundle['entry'].present?

        vitals = []
        medications = []
        labs = []
        conditions = []

        fhir_bundle['entry'].each do |entry|
          resource = entry['resource']
          next unless resource

          case resource['resourceType']
          when 'Observation'
            category = resource.dig('category', 0, 'coding', 0, 'code')
            text = resource.dig('code', 'text')
            value = resource.dig('valueQuantity', 'value')
            unit = resource.dig('valueQuantity', 'unit')

            if category == 'vital-signs' && text && value && unit
              vitals << "#{text}: #{value} #{unit}"
            elsif category == 'laboratory' && text && value && unit
              labs << "#{text}: #{value} #{unit}"
            end
          when 'MedicationRequest'
            medication_name = resource.dig('medicationCodeableConcept', 'text')
            medications << medication_name if medication_name
          when 'Condition'
            condition_name = resource.dig('code', 'text')
            conditions << condition_name if condition_name
          end
        end

        prompt_parts = ["Summarize the following patient's clinical information for a clinician.\n"]
        prompt_parts << "Vitals: #{vitals.join(', ')}\n" if vitals.present?
        prompt_parts << "Medications: #{medications.join(', ')}\n" if medications.present?
        prompt_parts << "Lab Results: #{labs.join(', ')}\n" if labs.present?
        prompt_parts << "Conditions: #{conditions.join(', ')}\n" if conditions.present?

        return nil if prompt_parts.size <= 1

        prompt_parts << "Generate a brief, clinically relevant summary in natural language."
        prompt_parts.join
      end

      def chat_params
        params.permit(
          :resourceType, :type, entry: [
            resource: [
              :resourceType,
              { category: [{ coding: [:system, :code] }] },
              { code: [:text] },
              { valueQuantity: [:value, :unit] },
              { medicationCodeableConcept: [:text] }
            ]
          ]
        )
      end
    end
  end
end
