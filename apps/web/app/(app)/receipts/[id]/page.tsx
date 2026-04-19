import { notFound } from "next/navigation";

import { PageHeader } from "@/components/common/page-header";
import { ReceiptReviewPanel } from "@/components/review/receipt-review-panel";
import { accountingEntries, auditHistory, receipts } from "@/lib/data/demo";

export default async function ReceiptDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const receipt = receipts.find((item) => item.id === id);
  if (!receipt) notFound();

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Receipt Detail"
        title={receipt.merchantName ?? "Receipt pending extraction"}
        description="Review extracted values, inspect audit history, and decide whether to approve, edit, retry, reject, or mark as duplicate."
      />
      <ReceiptReviewPanel receipt={receipt} accountingEntry={accountingEntries[receipt.id]} auditEvents={auditHistory[receipt.id] ?? []} />
    </div>
  );
}
