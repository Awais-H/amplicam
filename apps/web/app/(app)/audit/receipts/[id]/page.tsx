import { notFound } from "next/navigation";

import { AuditTimeline } from "@/components/audit/audit-timeline";
import { PageHeader } from "@/components/common/page-header";
import { auditHistory, receipts } from "@/lib/data/demo";

export default async function ReceiptAuditPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const receipt = receipts.find((item) => item.id === id);
  if (!receipt) notFound();

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Audit History"
        title={`Audit for ${receipt.merchantName ?? id}`}
        description="Every machine and human transition should be append-only and traceable from the uploaded receipt through the posted accounting entry."
      />
      <AuditTimeline events={auditHistory[id] ?? []} />
    </div>
  );
}
