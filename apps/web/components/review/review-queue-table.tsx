"use client";

import { useDeferredValue, useMemo, useState } from "react";
import Link from "next/link";

import { StatusBadge } from "@/components/common/status-badge";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import type { ReviewQueueItem } from "@/lib/types/entities";

export function ReviewQueueTable({ items }: { items: ReviewQueueItem[] }) {
  const [query, setQuery] = useState("");
  const [reasonFilter, setReasonFilter] = useState("all");
  const deferredQuery = useDeferredValue(query);

  const filtered = useMemo(() => {
    return items.filter((item) => {
      const matchesQuery =
        deferredQuery.length === 0 ||
        item.receipt.merchantName?.toLowerCase().includes(deferredQuery.toLowerCase()) ||
        item.receipt.id.toLowerCase().includes(deferredQuery.toLowerCase());

      const matchesReason = reasonFilter === "all" || item.reasons.includes(reasonFilter as ReviewQueueItem["reasons"][number]);
      return matchesQuery && matchesReason;
    });
  }, [deferredQuery, items, reasonFilter]);

  return (
    <div className="space-y-4">
      <div className="grid gap-3 md:grid-cols-[1fr_220px]">
        <Input placeholder="Search by merchant or receipt id" value={query} onChange={(event) => setQuery(event.target.value)} />
        <Select value={reasonFilter} onChange={(event) => setReasonFilter(event.target.value)}>
          <option value="all">All review reasons</option>
          <option value="HANDWRITTEN_TIP">Handwritten tip</option>
          <option value="UNRECONCILED_TOTALS">Unreconciled totals</option>
          <option value="DUPLICATE_SUSPECTED">Duplicate suspected</option>
        </Select>
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Receipt</TableHead>
            <TableHead>Amount</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Warnings</TableHead>
            <TableHead>Owner</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {filtered.map((item) => (
            <TableRow key={item.id}>
              <TableCell>
                <Link href={`/review/${item.receipt.id}`} className="space-y-1">
                  <p className="font-semibold text-foreground">{item.receipt.merchantName ?? "Receipt pending extraction"}</p>
                  <p className="text-xs uppercase tracking-[0.14em] text-mutedForeground">{item.receipt.id}</p>
                </Link>
              </TableCell>
              <TableCell>{item.receipt.total ? `${item.receipt.total.currency} ${item.receipt.total.amount}` : "Pending"}</TableCell>
              <TableCell>
                <StatusBadge status={item.receipt.status} />
              </TableCell>
              <TableCell>
                <div className="flex flex-wrap gap-2">
                  {item.reasons.map((reason) => (
                    <Badge key={reason} variant="warning">
                      {reason.replaceAll("_", " ")}
                    </Badge>
                  ))}
                </div>
              </TableCell>
              <TableCell>{item.assignedTo?.displayName ?? "Unassigned"}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

