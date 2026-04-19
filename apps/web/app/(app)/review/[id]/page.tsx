import { notFound } from "next/navigation";

import { PageHeader } from "@/components/common/page-header";
import { ReceiptReviewPanel } from "@/components/review/receipt-review-panel";
import { accountingEntries, auditHistory, receipts } from "@/lib/data/demo";

export default async function ReviewReceiptPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const receipt = receipts.find((item) => item.id === id);
  if (!receipt) notFound();

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Review Case"
        title={`Review ${receipt.merchantName ?? id}`}
        description="Side-by-side image preview, correction form, audit trail, and draft accounting entry preview."
      />
      <ReceiptReviewPanel receipt={receipt} accountingEntry={accountingEntries[receipt.id]} auditEvents={auditHistory[receipt.id] ?? []} />
    </div>
  );
}
