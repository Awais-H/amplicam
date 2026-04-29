export type ReceiptStatus =
  | "UPLOADED"
  | "PROCESSING"
  | "NEEDS_REVIEW"
  | "APPROVED"
  | "POSTED"
  | "DUPLICATE"
  | "REJECTED"
  | "FAILED";

export type ReviewReasonCode =
  | "LOW_IMAGE_QUALITY"
  | "UNRECONCILED_TOTALS"
  | "HANDWRITTEN_TIP"
  | "DUPLICATE_SUSPECTED"
  | "FOREIGN_CURRENCY"
  | "PARTIAL_RECEIPT"
  | "LOW_CATEGORY_CONFIDENCE"
  | "POLICY_BLOCKED"
  | "PROCESSING_FAILED"
  | "EXTRACTION_ATTEMPT_FAILED";

export interface MoneyValue {
  amount: string;
  currency: string;
}

export interface Receipt {
  id: string;
  status: ReceiptStatus;
  merchantName: string | null;
  merchantNormalized: string | null;
  receiptDate: string | null;
  subtotal: MoneyValue | null;
  tax: MoneyValue | null;
  tip: MoneyValue | null;
  serviceCharge: MoneyValue | null;
  total: MoneyValue | null;
  categoryCode: string | null;
  confidenceScore: number | null;
  needsHumanReview: boolean;
  reviewReasons: ReviewReasonCode[];
  sourceFileUrl: string | null;
  processingRun?: {
    id: string;
    runKind: string;
    status: string;
    errorClass: string | null;
    errorMessage: string | null;
    startedAt: string | null;
    finishedAt: string | null;
  } | null;
  createdAt: string;
  updatedAt: string;
}

export interface ReviewQueueItem {
  id: string;
  state: "pending" | "in_review" | "resolved";
  reasons: ReviewReasonCode[];
  receipt: Receipt;
  assignedTo?: {
    id: string;
    displayName: string;
  } | null;
  priority: number;
}

export interface AccountingEntryLine {
  id: string;
  lineType: "expense" | "tax" | "tip" | "service_charge" | "rounding";
  accountCode: string;
  amount: MoneyValue;
  metadata?: Record<string, unknown> | null;
}

export interface AccountingEntry {
  id: string;
  status: "draft" | "posted" | "exported" | "failed";
  transactionDate: string;
  merchantName: string | null;
  gross: MoneyValue;
  lines: AccountingEntryLine[];
  sourceProvenance: Record<string, unknown>;
}

export interface AuditEvent {
  id: string;
  eventType: string;
  actionSource: "user" | "system" | "model" | "job";
  actorDisplay?: string | null;
  before?: Record<string, unknown> | null;
  after: Record<string, unknown>;
  createdAt: string;
}
