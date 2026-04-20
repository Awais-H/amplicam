"use client";

import { useCallback, useEffect, useRef, useState } from "react";

import { fetchGraphql } from "@/lib/graphql/client";
import { RECEIPTS_QUERY } from "@/lib/graphql/queries";
import type { Receipt, ReceiptStatus } from "@/lib/types/entities";

interface ReceiptsResponse {
  receipts: {
    nodes: Receipt[];
    pageInfo: { hasNextPage: boolean; endCursor: string | null };
  };
}

interface UseReceiptsOptions {
  status?: ReceiptStatus;
  pollInterval?: number;
}

export function useReceipts({ status, pollInterval = 4000 }: UseReceiptsOptions = {}) {
  const [receipts, setReceipts] = useState<Receipt[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const mountedRef = useRef(true);

  const fetchReceipts = useCallback(async () => {
    try {
      const data = await fetchGraphql<ReceiptsResponse>(RECEIPTS_QUERY, {
        status,
        first: 50,
      });
      if (mountedRef.current) {
        setReceipts(data.receipts.nodes);
        setError(null);
      }
    } catch (err) {
      if (mountedRef.current) {
        setError(err instanceof Error ? err.message : "Failed to fetch receipts");
      }
    } finally {
      if (mountedRef.current) {
        setLoading(false);
      }
    }
  }, [status]);

  useEffect(() => {
    mountedRef.current = true;
    setLoading(true);
    fetchReceipts();

    const interval = setInterval(fetchReceipts, pollInterval);

    return () => {
      mountedRef.current = false;
      clearInterval(interval);
    };
  }, [fetchReceipts, pollInterval]);

  return { receipts, loading, error, refetch: fetchReceipts };
}
