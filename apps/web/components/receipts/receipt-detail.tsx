"use client";

import { Loader2 } from "lucide-react";

import { PageHeader } from "@/components/common/page-header";
import { ReceiptReviewPanel } from "@/components/review/receipt-review-panel";
import { useReceipt } from "@/hooks/use-receipt";

export function ReceiptDetail({ id }: { id: string }) {
  const { receipt, accountingEntry, loading, error } = useReceipt(id);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin text-mutedForeground" />
        <span className="ml-3 text-sm text-mutedForeground">Loading receipt…</span>
      </div>
    );
  }

  if (error || !receipt) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Receipt Detail" title="Receipt not found" description={error ?? "This receipt could not be loaded."} />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Receipt Detail"
        title={receipt.merchantName ?? "Receipt pending extraction"}
        description="Review extracted values and decide whether to approve, edit, retry, reject, or mark as duplicate."
      />
      <ReceiptReviewPanel receipt={receipt} accountingEntry={accountingEntry ?? undefined} />
    </div>
  );
}
