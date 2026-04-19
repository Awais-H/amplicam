import Link from "next/link";

import { MetricCard } from "@/components/common/metric-card";
import { PageHeader } from "@/components/common/page-header";
import { StatusBadge } from "@/components/common/status-badge";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { receipts } from "@/lib/data/demo";

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

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard label="Needs Review" value="1" detail="Handwritten tip and total verification are blocking posting." />
        <MetricCard label="Posted" value="1" detail="High-confidence office supplies receipt posted without review." />
        <MetricCard label="Processing" value="1" detail="A new upload is currently in the extraction worker queue." />
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Merchant</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Total</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Category</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {receipts.map((receipt) => (
                <TableRow key={receipt.id}>
                  <TableCell>
                    <Link href={`/receipts/${receipt.id}`} className="font-semibold">
                      {receipt.merchantName ?? "Pending extraction"}
                    </Link>
                  </TableCell>
                  <TableCell>{receipt.receiptDate ?? "Pending"}</TableCell>
                  <TableCell>{receipt.total ? `${receipt.total.currency} ${receipt.total.amount}` : "Pending"}</TableCell>
                  <TableCell>
                    <StatusBadge status={receipt.status} />
                  </TableCell>
                  <TableCell>{receipt.categoryCode?.replaceAll("_", " ") ?? "Awaiting classification"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
