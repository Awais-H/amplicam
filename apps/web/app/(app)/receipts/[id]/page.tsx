import { ReceiptDetail } from "@/components/receipts/receipt-detail";

export default async function ReceiptDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  return <ReceiptDetail id={id} />;
}
