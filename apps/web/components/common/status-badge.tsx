import { Badge } from "@/components/ui/badge";
import type { ReceiptStatus } from "@/lib/types/entities";

const statusVariant: Record<ReceiptStatus, "default" | "success" | "warning" | "outline"> = {
  UPLOADED: "outline",
  PROCESSING: "default",
  NEEDS_REVIEW: "warning",
  APPROVED: "default",
  POSTED: "success",
  DUPLICATE: "outline",
  REJECTED: "outline",
  FAILED: "warning"
};

export function StatusBadge({ status }: { status: ReceiptStatus }) {
  return <Badge variant={statusVariant[status]}>{status.replaceAll("_", " ")}</Badge>;
}

