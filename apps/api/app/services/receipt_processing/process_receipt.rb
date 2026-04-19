module ReceiptProcessing
  class ProcessReceipt
    def initialize(receipt:, processing_run:, actor: nil)
      @receipt = receipt
      @processing_run = processing_run
      @actor = actor
    end

    def call
      Receipt.transaction do
        receipt.lock!
        processing_run.update!(status: :running, started_at: Time.current)
        receipt.update!(status: :processing, current_processing_run: processing_run)

        extraction = ReceiptExtractionService.new(receipt:, processing_run:).call
        normalization = ReceiptNormalizationService.new(receipt:, extraction:, processing_run:).call
        category_decision = Classification::ExpenseClassificationService.new(receipt:, normalization:, extraction:).call
        duplicate_fingerprint = DuplicateDetectionService.new(receipt:, normalization:).call
        confidence_result = ConfidenceScoringService.new(
          receipt:,
          extraction:,
          normalization:,
          category_decision:,
          duplicate_fingerprint:
        ).call
        normalization.update!(
          confidence_breakdown_jsonb: normalization.confidence_breakdown_jsonb.merge(
            "score" => confidence_result.score,
            "reason_codes" => confidence_result.reason_codes,
            "hard_blocker" => confidence_result.hard_blocker
          )
        )

        DecisionEngine.new(
          receipt:,
          normalization:,
          category_decision:,
          confidence_result:,
          actor:
        ).call

        processing_run.update!(status: :succeeded, finished_at: Time.current)
      end
    rescue StandardError => error
      processing_run.update!(
        status: :failed,
        error_class: error.class.name,
        error_message: error.message,
        finished_at: Time.current
      )
      Review::ReviewQueueService.new(receipt:).enqueue!(reason_codes: ["processing_failed"])
      receipt.update!(status: :failed)
      raise
    end

    private

    attr_reader :receipt, :processing_run, :actor
  end
end
