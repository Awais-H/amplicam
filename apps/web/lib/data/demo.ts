import type { AccountingEntry, AuditEvent, Receipt, ReviewQueueItem } from "@/lib/types/entities";

const usd = (amount: string) => ({ amount, currency: "USD" });

export const receipts: Receipt[] = [
  {
    id: "rcpt_01",
    status: "NEEDS_REVIEW",
    merchantName: "Harbor Grill",
    merchantNormalized: "Harbor Grill",
    receiptDate: "2026-04-10",
    subtotal: usd("48.00"),
    tax: usd("4.20"),
    tip: usd("9.60"),
    serviceCharge: usd("0.00"),
    total: usd("61.80"),
    categoryCode: "meals_and_entertainment",
    confidenceScore: 0.68,
    needsHumanReview: true,
    reviewReasons: ["HANDWRITTEN_TIP"],
    sourceFileUrl: null,
    createdAt: "2026-04-10T14:10:00Z",
    updatedAt: "2026-04-10T14:12:00Z"
  },
  {
    id: "rcpt_02",
    status: "POSTED",
    merchantName: "Staples",
    merchantNormalized: "Staples",
    receiptDate: "2026-04-08",
    subtotal: usd("86.99"),
    tax: usd("6.96"),
    tip: usd("0.00"),
    serviceCharge: usd("0.00"),
    total: usd("93.95"),
    categoryCode: "office_supplies",
    confidenceScore: 0.96,
    needsHumanReview: false,
    reviewReasons: [],
    sourceFileUrl: null,
    createdAt: "2026-04-08T13:00:00Z",
    updatedAt: "2026-04-08T13:02:00Z"
  },
  {
    id: "rcpt_03",
    status: "PROCESSING",
    merchantName: null,
    merchantNormalized: null,
    receiptDate: null,
    subtotal: null,
    tax: null,
    tip: null,
    serviceCharge: null,
    total: null,
    categoryCode: null,
    confidenceScore: null,
    needsHumanReview: false,
    reviewReasons: [],
    sourceFileUrl: null,
    createdAt: "2026-04-19T10:30:00Z",
    updatedAt: "2026-04-19T10:31:00Z"
  }
];

export const reviewQueue: ReviewQueueItem[] = [
  {
    id: "review_01",
    state: "pending",
    reasons: ["HANDWRITTEN_TIP"],
    receipt: receipts[0],
    assignedTo: { id: "user_01", displayName: "Awais Hashar" },
    priority: 20
  }
];

export const accountingEntries: Record<string, AccountingEntry> = {
  rcpt_01: {
    id: "entry_01",
    status: "draft",
    transactionDate: "2026-04-10",
    merchantName: "Harbor Grill",
    gross: usd("61.80"),
    lines: [
      { id: "line_01", lineType: "expense", accountCode: "meals_and_entertainment", amount: usd("48.00") },
      { id: "line_02", lineType: "tax", accountCode: "sales_tax_paid", amount: usd("4.20") },
      { id: "line_03", lineType: "tip", accountCode: "expense_tip", amount: usd("9.60") }
    ],
    sourceProvenance: {
      receiptId: "rcpt_01",
      modelName: "gemini-2.5-flash",
      promptVersion: "2026-04-19.v1"
    }
  },
  rcpt_02: {
    id: "entry_02",
    status: "posted",
    transactionDate: "2026-04-08",
    merchantName: "Staples",
    gross: usd("93.95"),
    lines: [
      { id: "line_04", lineType: "expense", accountCode: "office_supplies", amount: usd("86.99") },
      { id: "line_05", lineType: "tax", accountCode: "sales_tax_paid", amount: usd("6.96") }
    ],
    sourceProvenance: {
      receiptId: "rcpt_02",
      reviewer: "system"
    }
  }
};

export const auditHistory: Record<string, AuditEvent[]> = {
  rcpt_01: [
    {
      id: "audit_01",
      eventType: "receipt.created",
      actionSource: "user",
      actorDisplay: "Awais Hashar",
      after: { filename: "harbor-grill.jpg", source: "mobile_scan" },
      createdAt: "2026-04-10T14:10:00Z"
    },
    {
      id: "audit_02",
      eventType: "receipt.extracted",
      actionSource: "model",
      actorDisplay: null,
      after: { modelName: "gemini-2.5-flash", promptVersion: "2026-04-19.v1" },
      createdAt: "2026-04-10T14:11:00Z"
    },
    {
      id: "audit_03",
      eventType: "receipt.review_queued",
      actionSource: "system",
      actorDisplay: null,
      after: { reasonCodes: ["HANDWRITTEN_TIP"] },
      createdAt: "2026-04-10T14:12:00Z"
    }
  ]
};

