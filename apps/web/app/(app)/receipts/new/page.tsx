import { PageHeader } from "@/components/common/page-header";
import { UploadCard } from "@/components/receipts/upload-card";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function NewReceiptPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="New Receipt"
        title="Ingest a receipt into the workflow"
        description="The upload flow should request direct-upload metadata from GraphQL, stream the file to Active Storage, then create the receipt record and enqueue processing."
      />

      <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <UploadCard />
        <Card>
          <CardHeader>
            <CardTitle>Implementation notes</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 text-sm text-mutedForeground">
            <p>1. Call `initiateReceiptUpload` with filename, checksum, byte size, and mime type.</p>
            <p>2. Upload directly to private object storage using the signed upload URL.</p>
            <p>3. Call `createReceipt` with `blobSignedId` to attach the file and enqueue processing.</p>
            <p>4. Redirect to the receipt detail page and poll for status updates.</p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

