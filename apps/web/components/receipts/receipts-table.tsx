"use client";

import Link from "next/link";
import { Loader2 } from "lucide-react";

import { StatusBadge } from "@/components/common/status-badge";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useReceipts } from "@/hooks/use-receipts";

export function ReceiptsTable() {
  const { receipts, loading, error } = useReceipts({ pollInterval: 4000 });

  if (loading && receipts.length === 0) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-mutedForeground" />
          <span className="ml-3 text-sm text-mutedForeground">Loading receipts…</span>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-sm text-mutedForeground">
          <p className="font-semibold text-destructive">Failed to load receipts</p>
          <p className="mt-2">{error}</p>
        </CardContent>
      </Card>
    );
  }

  if (receipts.length === 0) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-sm text-mutedForeground">
          No receipts yet. Upload one to get started.
        </CardContent>
      </Card>
    );
  }

  const counts = {
    needsReview: receipts.filter((r) => r.status === "NEEDS_REVIEW").length,
    posted: receipts.filter((r) => r.status === "POSTED").length,
    processing: receipts.filter((r) => r.status === "PROCESSING" || r.status === "UPLOADED").length,
  };

  return (
    <>
      <div className="grid gap-4 md:grid-cols-3">
        <SummaryCard label="Needs Review" value={counts.needsReview} />
        <SummaryCard label="Posted" value={counts.posted} />
        <SummaryCard label="Processing" value={counts.processing} />
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
                  <TableCell>{receipt.receiptDate ?? "—"}</TableCell>
                  <TableCell>
                    {receipt.total ? `${receipt.total.currency} ${receipt.total.amount}` : "—"}
                  </TableCell>
                  <TableCell>
                    <StatusBadge status={receipt.status} />
                  </TableCell>
                  <TableCell>{receipt.categoryCode?.replaceAll("_", " ") ?? "—"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </>
  );
}

function SummaryCard({ label, value }: { label: string; value: number }) {
  return (
    <Card>
      <CardContent className="py-4">
        <p className="text-sm text-mutedForeground">{label}</p>
        <p className="mt-1 text-2xl font-bold">{value}</p>
      </CardContent>
    </Card>
  );
}
