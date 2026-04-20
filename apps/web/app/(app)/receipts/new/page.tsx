import { PageHeader } from "@/components/common/page-header";
import { UploadCard } from "@/components/receipts/upload-card";

export default function NewReceiptPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="New Receipt"
        title="Upload a receipt"
        description="Select a receipt image or PDF. The file will be uploaded to private storage, then extraction, classification, and confidence scoring will run automatically."
      />

      <div className="mx-auto max-w-2xl">
        <UploadCard />
      </div>
    </div>
  );
}
