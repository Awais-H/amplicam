import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import type { AccountingEntry, Receipt } from "@/lib/types/entities";

function reviewReasonsSummary(reasons: string[]): string {
  const upper = reasons.map((r) => r.toUpperCase());
  if (upper.includes("EXTRACTION_ATTEMPT_FAILED")) {
    return "A later automatic parse attempt failed. The values below are still from your last successful extraction — edit as needed or use Retry extraction.";
  }
  return reasons.join(", ").replaceAll("_", " ");
}

export function ReceiptReviewPanel({
  receipt,
  accountingEntry
}: {
  receipt: Receipt;
  accountingEntry?: AccountingEntry;
}) {
  return (
    <div className="grid gap-6 xl:grid-cols-[1.2fr_1fr]">
      <Card className="overflow-hidden">
        <CardHeader>
          <CardTitle>Receipt Image</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex min-h-[520px] items-center justify-center rounded-[24px] border border-dashed border-white/55 bg-white/35 p-10 dark:border-white/12 dark:bg-white/5">
            <div className="max-w-sm rounded-2xl border border-white/50 bg-white/80 p-6 text-center shadow-panel backdrop-blur-sm dark:border-white/10 dark:bg-slate-900/70">
              <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">Preview</p>
              <p className="mt-4 text-lg font-bold text-neutral-900 dark:text-white">{receipt.merchantName ?? "Awaiting extraction"}</p>
              <p className="mt-2 text-sm text-neutral-600 dark:text-neutral-400">
                Private file rendering will use signed Active Storage URLs once connected to the GraphQL receipt query.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="space-y-6">
        {receipt.reviewReasons.length > 0 ? (
          <Alert>
            <p className="font-semibold">Review required</p>
            <p className="mt-2 text-sm text-mutedForeground">{reviewReasonsSummary(receipt.reviewReasons)}</p>
          </Alert>
        ) : null}

        <Tabs>
          <TabsList>
            <TabsTrigger>Overview</TabsTrigger>
            <TabsTrigger>Entry</TabsTrigger>
          </TabsList>

          <TabsContent className="space-y-4">
            <div className="grid gap-3 md:grid-cols-2">
              <Input defaultValue={receipt.merchantName ?? ""} placeholder="Merchant name" />
              <Input defaultValue={receipt.receiptDate ?? ""} placeholder="Receipt date" />
              <Input defaultValue={receipt.subtotal?.amount ?? ""} placeholder="Subtotal" />
              <Input defaultValue={receipt.tax?.amount ?? ""} placeholder="Tax" />
              <Input defaultValue={receipt.tip?.amount ?? ""} placeholder="Tip" />
              <Input defaultValue={receipt.total?.amount ?? ""} placeholder="Total" />
            </div>
            <Select
              value={receipt.categoryCode ?? "uncategorized_review_required"}
              onChange={() => {}}
              title="Category is assigned automatically when the receipt is processed; it refreshes here as data loads."
            >
              <option value="meals_and_entertainment">Meals & entertainment</option>
              <option value="travel_transportation">Travel & transportation</option>
              <option value="lodging">Lodging</option>
              <option value="office_supplies">Office supplies</option>
              <option value="software_subscriptions">Software & subscriptions</option>
              <option value="telecom_internet">Telecom & internet</option>
              <option value="fuel">Fuel</option>
              <option value="parking_and_tolls">Parking & tolls</option>
              <option value="shipping_and_courier">Shipping & courier</option>
              <option value="professional_services">Professional services</option>
              <option value="miscellaneous_expense">Miscellaneous</option>
              <option value="uncategorized_review_required">Uncategorized / review</option>
            </Select>
            <div className="flex flex-wrap gap-3">
              <Button>Approve and Post</Button>
              <Button variant="secondary">Retry Extraction</Button>
              <Button variant="secondary">Mark Duplicate</Button>
              <Button variant="destructive">Reject</Button>
            </div>
          </TabsContent>

          <TabsContent className="space-y-4">
            {accountingEntry ? (
              <>
                <div className="rounded-2xl bg-accent/40 p-4 text-sm">
                  <p className="font-semibold">Gross amount</p>
                  <p className="mt-1 text-mutedForeground">
                    {accountingEntry.gross.currency} {accountingEntry.gross.amount}
                  </p>
                </div>
                <div className="space-y-3">
                  {accountingEntry.lines.map((line) => (
                    <div key={line.id} className="flex items-center justify-between rounded-xl border border-border p-3">
                      <div>
                        <p className="font-medium capitalize">{line.lineType.replaceAll("_", " ")}</p>
                        <p className="text-sm text-mutedForeground">{line.accountCode}</p>
                      </div>
                      <p className="font-semibold">
                        {line.amount.currency} {line.amount.amount}
                      </p>
                    </div>
                  ))}
                </div>
              </>
            ) : (
              <p className="text-sm text-mutedForeground">No accounting entry has been created for this receipt yet.</p>
            )}
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

