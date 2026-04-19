import { PageHeader } from "@/components/common/page-header";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";

export default function PoliciesPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Organization Policies"
        title="Configure posting and classification defaults"
        description="Jurisdiction-specific rules and company policy should stay configurable. Conservative auto-post should only unlock when thresholds and routing rules are explicit."
      />

      <div className="grid gap-6 xl:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Posting policy</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Select defaultValue="review_only">
              <option value="review_only">Review only</option>
              <option value="conservative_auto_post">Conservative auto-post</option>
            </Select>
            <Input defaultValue="0.90" placeholder="Auto-post threshold" />
            <Button>Save posting policy</Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Tax and category policy</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Input defaultValue="2" placeholder="Rounding tolerance (cents)" />
            <Input defaultValue="USD" placeholder="Base currency" />
            <Input defaultValue="sales_tax_paid" placeholder="Tax account code" />
            <Button variant="secondary">Save policy JSON</Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

