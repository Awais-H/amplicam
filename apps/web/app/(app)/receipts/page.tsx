import Link from "next/link";

import { PageHeader } from "@/components/common/page-header";
import { ReceiptsTable } from "@/components/receipts/receipts-table";
import { buttonVariants } from "@/components/ui/button";

export default function ReceiptsPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Receipt Inbox"
        title="Track extraction, review, and posting"
        description="Receipts move from direct upload to AI extraction, then either conservative auto-post or human review depending on confidence and policy."
        actions={
          <Link href="/receipts/new" className={buttonVariants()}>
            Upload receipt
          </Link>
        }
      />

      <ReceiptsTable />
    </div>
  );
}
