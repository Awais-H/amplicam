require "uri"

module Mutations
  class InitiateReceiptUpload < Types::BaseMutation
    argument :filename, String, required: true
    argument :byte_size, Integer, required: true
    argument :checksum, String, required: true
    argument :content_type, String, required: true

    field :blob_signed_id, String, null: false
    field :upload_url, String, null: false
    field :headers, Types::Scalars::JsonType, null: false

    def resolve(filename:, byte_size:, checksum:, content_type:)
      authorize_record!(Receipt, :create?)
      blob = Receipts::DirectUploadService.new(
        filename:,
        byte_size:,
        checksum:,
        content_type:
      ).call

      {
        blob_signed_id: blob.signed_id,
        upload_url: normalized_upload_url(blob.service_url_for_direct_upload),
        headers: blob.service_headers_for_direct_upload
      }
    end

    private

    def normalized_upload_url(url)
      return url unless Rails.application.config.active_storage.service == :local

      uri = URI.parse(url)
      [uri.path.presence, uri.query.presence && "?#{uri.query}"].compact.join
    rescue URI::InvalidURIError
      url
    end
  end
end
