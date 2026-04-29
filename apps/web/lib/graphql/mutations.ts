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

export const APPROVE_RECEIPT = `
  mutation ApproveReceipt($receiptId: ID!, $comment: String) {
    approveReceipt(input: { receiptId: $receiptId, comment: $comment }) {
      receipt {
        id
        status
      }
      accountingEntry {
        id
      }
    }
  }
`;

export const RETRY_RECEIPT_EXTRACTION = `
  mutation RetryReceiptExtraction($receiptId: ID!, $reason: String) {
    retryReceiptExtraction(input: { receiptId: $receiptId, reason: $reason }) {
      receipt {
        id
        status
      }
    }
  }
`;

export const REJECT_RECEIPT = `
  mutation RejectReceipt($receiptId: ID!, $reason: String!) {
    rejectReceipt(input: { receiptId: $receiptId, reason: $reason }) {
      receipt {
        id
        status
      }
    }
  }
`;
