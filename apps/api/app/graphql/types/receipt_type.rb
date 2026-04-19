module Types
  class ReceiptType < BaseObject
    field :id, ID, null: false
    field :status, Types::ReceiptStatusEnum, null: false
    field :merchant_name, String, null: true
    field :merchant_normalized, String, null: true
    field :receipt_date, GraphQL::Types::ISO8601Date, null: true
    field :subtotal, Types::MoneyType, null: true
    field :tax, Types::MoneyType, null: true
    field :tip, Types::MoneyType, null: true
    field :service_charge, Types::MoneyType, null: true
    field :total, Types::MoneyType, null: true
    field :category_code, String, null: true
    field :confidence_score, Float, null: true
    field :needs_human_review, Boolean, null: false
    field :review_reasons, [Types::ReviewReasonCodeEnum], null: false
    field :source_file_url, String, null: true
    field :processing_run, Types::ProcessingRunType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def merchant_name
      object.current_normalization&.merchant_name
    end

    def merchant_normalized
      object.current_normalization&.merchant_normalized
    end

    def receipt_date
      object.current_normalization&.receipt_date
    end

    def subtotal
      money(object.current_normalization&.subtotal_amount_cents)
    end

    def tax
      money(object.current_normalization&.tax_amount_cents)
    end

    def tip
      money(object.current_normalization&.tip_amount_cents)
    end

    def service_charge
      money(object.current_normalization&.service_charge_amount_cents)
    end

    def total
      money(object.current_normalization&.total_amount_cents)
    end

    def category_code
      object.category_decisions.order(created_at: :desc).first&.category_code
    end

    def confidence_score
      object.current_normalization&.confidence_breakdown_jsonb&.dig("score")
    end

    def needs_human_review
      object.review_required? || object.failed?
    end

    def review_reasons
      Array(object.review_queue_item&.reason_codes_jsonb)
    end

    def source_file_url
      return unless object.source_file.attached?

      Rails.application.routes.url_helpers.rails_blob_path(object.source_file, only_path: true)
    rescue StandardError
      nil
    end

    def processing_run
      object.current_processing_run
    end

    private

    def money(cents)
      Support::Money.payload(cents:, currency: object.current_normalization&.currency)
    end
  end
end

