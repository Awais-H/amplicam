import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import type { AccountingEntry, AuditEvent, Receipt } from "@/lib/types/entities";

export function ReceiptReviewPanel({
  receipt,
  accountingEntry,
  auditEvents
}: {
  receipt: Receipt;
  accountingEntry?: AccountingEntry;
  auditEvents: AuditEvent[];
}) {
  return (
    <div className="grid gap-6 xl:grid-cols-[1.2fr_1fr]">
      <Card className="overflow-hidden">
        <CardHeader>
          <CardTitle>Receipt Image</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex min-h-[520px] items-center justify-center rounded-[24px] border border-dashed border-border bg-[radial-gradient(circle_at_top,_rgba(167,139,250,0.08),_transparent_35%),linear-gradient(135deg,rgba(15,23,42,0.04),rgba(234,179,8,0.12))] p-10">
            <div className="max-w-sm rounded-2xl bg-background/90 p-6 text-center shadow-panel">
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-mutedForeground">Preview</p>
              <p className="mt-4 text-lg font-semibold">{receipt.merchantName ?? "Awaiting extraction"}</p>
              <p className="mt-2 text-sm text-mutedForeground">
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
            <p className="mt-2 text-sm text-mutedForeground">{receipt.reviewReasons.join(", ").replaceAll("_", " ")}</p>
          </Alert>
        ) : null}

        <Tabs>
          <TabsList>
            <TabsTrigger>Overview</TabsTrigger>
            <TabsTrigger>Audit</TabsTrigger>
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
            <Select defaultValue={receipt.categoryCode ?? "uncategorized_review_required"}>
              <option value="meals_and_entertainment">Meals & entertainment</option>
              <option value="travel_transportation">Travel & transportation</option>
              <option value="office_supplies">Office supplies</option>
              <option value="lodging">Lodging</option>
              <option value="fuel">Fuel</option>
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
            {auditEvents.map((event) => (
              <div key={event.id} className="space-y-2">
                <div className="flex items-center justify-between gap-3">
                  <p className="font-semibold">{event.eventType}</p>
                  <p className="text-xs uppercase tracking-[0.16em] text-mutedForeground">{event.actionSource}</p>
                </div>
                <p className="text-sm text-mutedForeground">{new Date(event.createdAt).toLocaleString()}</p>
                <pre className="overflow-x-auto rounded-xl bg-accent/50 p-3 text-xs text-foreground">
                  {JSON.stringify(event.after, null, 2)}
                </pre>
                <Separator />
              </div>
            ))}
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

