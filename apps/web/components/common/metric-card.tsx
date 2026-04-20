import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function MetricCard({
  label,
  value,
  detail
}: {
  label: string;
  value: string;
  detail: string;
}) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="text-sm font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">{label}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        <p className="text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">{value}</p>
        <p className="text-sm text-neutral-600 dark:text-neutral-400">{detail}</p>
      </CardContent>
    </Card>
  );
}

