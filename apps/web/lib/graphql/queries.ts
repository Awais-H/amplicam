export const RECEIPTS_QUERY = `
  query Receipts($status: ReceiptStatusEnum, $first: Int, $after: String) {
    receipts(status: $status, first: $first, after: $after) {
      nodes {
        id
        status
        merchantName
        merchantNormalized
        receiptDate
        subtotal { amount currency }
        tax { amount currency }
        tip { amount currency }
        serviceCharge { amount currency }
        total { amount currency }
        categoryCode
        confidenceScore
        needsHumanReview
        reviewReasons
        sourceFileUrl
        createdAt
        updatedAt
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`;

export const RECEIPT_QUERY = `
  query Receipt($id: ID!) {
    receipt(id: $id) {
      id
      status
      merchantName
      merchantNormalized
      receiptDate
      subtotal { amount currency }
      tax { amount currency }
      tip { amount currency }
      serviceCharge { amount currency }
      total { amount currency }
      categoryCode
      confidenceScore
      needsHumanReview
      reviewReasons
      sourceFileUrl
      createdAt
      updatedAt
    }
    accountingEntry(receiptId: $id) {
      id
      status
      transactionDate
      merchantName
      gross { amount currency }
      lines {
        id
        lineType
        accountCode
        amount { amount currency }
      }
      sourceProvenance
    }
  }
`;
