"use client";

import { startTransition, useMemo, useState } from "react";
import { FileUp, ShieldCheck } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";

export function UploadCard() {
  const [filename, setFilename] = useState<string | null>(null);
  const [progress, setProgress] = useState(0);

  const progressLabel = useMemo(() => {
    if (!filename) return "Choose a receipt image or PDF to start extraction.";
    if (progress >= 100) return "Upload prepared. Next step: direct upload + createReceipt mutation.";
    return `Preparing ${filename} for upload.`;
  }, [filename, progress]);

  return (
    <Card className="overflow-hidden">
      <CardHeader>
        <CardTitle>Receipt Intake</CardTitle>
        <CardDescription>
          Validate the file locally, stream it to private storage, and create a receipt record before background processing begins.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <label className="flex min-h-52 cursor-pointer flex-col items-center justify-center rounded-[24px] border border-dashed border-border bg-accent/40 p-8 text-center">
          <FileUp className="mb-4 h-10 w-10 text-primary" />
          <p className="text-lg font-semibold">Drop a receipt or browse</p>
          <p className="mt-2 max-w-md text-sm text-mutedForeground">{progressLabel}</p>
          <input
            className="hidden"
            type="file"
            accept="image/*,application/pdf"
            onChange={(event) => {
              const file = event.target.files?.[0];
              if (!file) return;

              startTransition(() => {
                setFilename(file.name);
                setProgress(35);
                window.setTimeout(() => setProgress(72), 250);
                window.setTimeout(() => setProgress(100), 500);
              });
            }}
          />
        </label>

        <div className="h-3 overflow-hidden rounded-full bg-accent">
          <div className="h-full rounded-full bg-primary transition-all" style={{ width: `${progress}%` }} />
        </div>

        <div className="rounded-2xl bg-card p-4 text-sm text-mutedForeground">
          <div className="flex items-center gap-2 text-foreground">
            <ShieldCheck className="h-4 w-4 text-success" />
            Upload policy
          </div>
          <ul className="mt-3 space-y-2">
            <li>Private object storage only</li>
            <li>Accepted types: JPEG, PNG, HEIC, PDF</li>
            <li>Large or ambiguous receipts remain human-reviewable</li>
          </ul>
        </div>
      </CardContent>
      <CardFooter>
        <Button>Prepare Direct Upload</Button>
        <Button variant="secondary">Open API Contract</Button>
      </CardFooter>
    </Card>
  );
}

