export const INITIATE_RECEIPT_UPLOAD = `
  mutation InitiateReceiptUpload(
    $filename: String!
    $byteSize: Int!
    $checksum: String!
    $contentType: String!
  ) {
    initiateReceiptUpload(
      input: {
        filename: $filename
        byteSize: $byteSize
        checksum: $checksum
        contentType: $contentType
      }
    ) {
      blobSignedId
      uploadUrl
      headers
    }
  }
`;

export const CREATE_RECEIPT = `
  mutation CreateReceipt($blobSignedId: String!, $source: String) {
    createReceipt(input: { blobSignedId: $blobSignedId, source: $source }) {
      receipt {
        id
        status
        createdAt
      }
    }
  }
`;
