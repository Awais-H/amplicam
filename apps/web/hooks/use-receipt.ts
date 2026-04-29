"use client";

import { useCallback, useEffect, useRef, useState } from "react";

import { fetchGraphql } from "@/lib/graphql/client";
import { RECEIPT_QUERY } from "@/lib/graphql/queries";
import type { AccountingEntry, Receipt } from "@/lib/types/entities";

interface ReceiptResponse {
  receipt: Receipt | null;
  accountingEntry: AccountingEntry | null;
}

const SETTLED_STATUSES = new Set(["NEEDS_REVIEW", "APPROVED", "POSTED", "DUPLICATE", "REJECTED", "FAILED"]);

export function useReceipt(id: string) {
  const [receipt, setReceipt] = useState<Receipt | null>(null);
  const [accountingEntry, setAccountingEntry] = useState<AccountingEntry | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const mountedRef = useRef(true);
  const receiptRef = useRef<Receipt | null>(null);

  const fetchReceipt = useCallback(async () => {
    try {
      const data = await fetchGraphql<ReceiptResponse>(RECEIPT_QUERY, { id });
      if (!mountedRef.current) return;

      receiptRef.current = data.receipt;
      setReceipt(data.receipt);
      setAccountingEntry(data.accountingEntry);
      setError(null);
    } catch (err) {
      if (mountedRef.current) {
        setError(err instanceof Error ? err.message : "Failed to fetch receipt");
      }
    } finally {
      if (mountedRef.current) setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    mountedRef.current = true;
    setLoading(true);
    fetchReceipt();

    const interval = setInterval(() => {
      const status = receiptRef.current?.status;
      if (!status || !SETTLED_STATUSES.has(status)) {
        fetchReceipt();
      }
    }, 3000);

    return () => {
      mountedRef.current = false;
      clearInterval(interval);
    };
  }, [fetchReceipt]);

  return { receipt, accountingEntry, loading, error, refetch: fetchReceipt };
}
