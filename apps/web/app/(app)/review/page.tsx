import { MetricCard } from "@/components/common/metric-card";
import { PageHeader } from "@/components/common/page-header";
import { ReviewQueueTable } from "@/components/review/review-queue-table";
import { reviewQueue } from "@/lib/data/demo";

export default function ReviewQueuePage() {
  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Human Review"
        title="Work the review queue with context"
        description="Reviewers verify the receipt image, extracted fields, reconciliation status, duplicate risk, and policy warnings before posting."
      />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard label="Open queue" value={`${reviewQueue.length}`} detail="Conservative routing keeps ambiguous receipts out of auto-post." />
        <MetricCard label="Average score" value="0.68" detail="Only receipts above the strict threshold can post automatically." />
        <MetricCard label="Top blocker" value="Tip" detail="Handwritten gratuity still needs a reviewer in phase 1." />
      </div>

      <ReviewQueueTable items={reviewQueue} />
    </div>
  );
}

