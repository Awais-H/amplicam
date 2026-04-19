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
        upload_url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      }
    end
  end
end

