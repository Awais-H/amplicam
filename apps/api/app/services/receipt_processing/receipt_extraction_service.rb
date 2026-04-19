module ReceiptProcessing
  class ReceiptExtractionService
    def initialize(receipt:, processing_run:, client: Ai::GeminiClient.new)
      @receipt = receipt
      @processing_run = processing_run
      @client = client
    end

    def call
      result = client.extract_receipt!(
        image_parts: build_image_parts,
        organization: receipt.organization
      )

      errors = JSONSchemer.schema(Ai::ReceiptExtractionPrompt.schema).validate(result[:parsed_fields]).to_a
      raise "ReceiptExtractionSchemaError: #{errors.map { |error| error['data_pointer'] }.join(', ')}" if errors.any?

      extraction = receipt.receipt_extractions.create!(
        processing_run:,
        model_name: result[:model_name],
        prompt_version: Ai::ReceiptExtractionPrompt::VERSION,
        raw_model_output: result[:raw_model_output],
        parsed_fields: result[:parsed_fields],
        reasoning_summary: result[:reasoning_summary],
        model_confidence: result[:model_confidence],
        token_usage_jsonb: result[:token_usage]
      )

      receipt.update!(current_extraction: extraction)

      Audit::AuditLogService.record!(
        event_type: "receipt.extracted",
        organization: receipt.organization,
        auditable: receipt,
        after: {
          extraction_id: extraction.id,
          model_name: extraction.model_name,
          prompt_version: extraction.prompt_version
        },
        action_source: "model"
      )

      extraction
    end

    private

    attr_reader :receipt, :processing_run, :client

    def build_image_parts
      data = Base64.strict_encode64(receipt.source_file.download)
      [
        {
          inline_data: {
            mime_type: receipt.mime_type || receipt.source_file.blob.content_type,
            data:
          }
        }
      ]
    end
  end
end

