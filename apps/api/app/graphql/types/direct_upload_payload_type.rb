module Types
  class DirectUploadPayloadType < BaseObject
    field :blob_signed_id, String, null: false
    field :upload_url, String, null: false
    field :headers, Types::Scalars::JsonType, null: false
  end
end

