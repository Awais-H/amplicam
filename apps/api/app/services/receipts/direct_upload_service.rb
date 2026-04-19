module Receipts
  class DirectUploadService
    ALLOWED_CONTENT_TYPES = ["image/jpeg", "image/png", "image/heic", "application/pdf"].freeze
    MAX_FILE_SIZE = 15 * 1024 * 1024

    def initialize(filename:, byte_size:, checksum:, content_type:)
      @filename = filename
      @byte_size = byte_size
      @checksum = checksum
      @content_type = content_type
    end

    def call
      validate!

      ActiveStorage::Blob.create_before_direct_upload!(
        filename:,
        byte_size:,
        checksum:,
        content_type:
      )
    end

    private

    attr_reader :filename, :byte_size, :checksum, :content_type

    def validate!
      raise ArgumentError, "Unsupported content type" unless ALLOWED_CONTENT_TYPES.include?(content_type)
      raise ArgumentError, "File too large" if byte_size.to_i > MAX_FILE_SIZE
      raise ArgumentError, "Checksum required" if checksum.blank?
      raise ArgumentError, "Filename required" if filename.blank?
    end
  end
end

