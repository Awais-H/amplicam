"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useRef, useState } from "react";
import { AlertCircle, CheckCircle2, FileUp, Loader2, ShieldCheck } from "lucide-react";

import { Button, buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useReceiptUpload } from "@/hooks/use-receipt-upload";

const STAGE_LABELS: Record<string, string> = {
  idle: "Choose a receipt image or PDF to start extraction.",
  selected: "Ready to upload. Click \"Upload & Process\" to begin.",
  hashing: "Computing file checksum…",
  initiating: "Requesting upload credentials…",
  uploading: "Uploading to private storage…",
  creating: "Creating receipt and enqueuing processing…",
  done: "Receipt created and processing has begun.",
};

export function UploadCard() {
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const { stage, progress, error, createdReceiptId, upload, reset } = useReceiptUpload();

  const isUploading = !["idle", "selected", "done"].includes(stage);

  function handleFileSelection(file: File | null) {
    if (!file) return;
    reset();
    setSelectedFile(file);
  }

  async function handleUpload() {
    if (!selectedFile) {
      inputRef.current?.click();
      return;
    }
    if (isUploading) return;

    const receiptId = await upload(selectedFile);
    if (receiptId) {
      router.push(`/receipts/${receiptId}`);
    }
  }

  const fileDetails = selectedFile
    ? {
        name: selectedFile.name,
        type: selectedFile.type || "unknown",
        size: `${(selectedFile.size / 1024 / 1024).toFixed(2)} MB`,
      }
    : null;

  return (
    <Card className="overflow-hidden">
      <CardHeader>
        <CardTitle>Receipt Intake</CardTitle>
        <CardDescription>
          Upload a receipt to private storage. The system will extract data, classify, and either auto-post or queue for review.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <label className="flex min-h-52 cursor-pointer flex-col items-center justify-center rounded-[24px] border border-dashed border-white/60 bg-white/40 p-8 text-center transition-colors hover:border-sky-300/60 hover:bg-white/55 dark:border-white/15 dark:bg-white/5 dark:hover:border-sky-500/30 dark:hover:bg-white/10">
          <FileUp className="mb-4 h-10 w-10 text-neutral-800 dark:text-neutral-200" />
          <p className="text-lg font-bold text-neutral-900 dark:text-white">Drop a receipt or browse</p>
          <p className="mt-2 max-w-md text-sm text-neutral-600 dark:text-neutral-400">
            {STAGE_LABELS[stage] ?? STAGE_LABELS.idle}
          </p>
          <input
            ref={inputRef}
            className="hidden"
            type="file"
            accept="image/*,application/pdf"
            disabled={isUploading}
            onChange={(event) => {
              handleFileSelection(event.target.files?.[0] ?? null);
            }}
          />
        </label>

        <div className="h-3 overflow-hidden rounded-full bg-neutral-200/80 dark:bg-white/10">
          <div
            className="h-full rounded-full bg-neutral-900 transition-all duration-300 dark:bg-white"
            style={{ width: `${progress}%` }}
          />
        </div>

        {error ? (
          <div className="flex items-start gap-3 rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm">
            <AlertCircle className="mt-0.5 h-5 w-5 shrink-0 text-destructive" />
            <div>
              <p className="font-semibold text-foreground">Upload failed</p>
              <p className="mt-1 text-mutedForeground">{error}</p>
            </div>
          </div>
        ) : null}

        {fileDetails ? (
          <div className="rounded-2xl border border-white/50 bg-white/50 p-4 text-sm dark:border-white/10 dark:bg-white/5">
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="font-semibold text-foreground">{fileDetails.name}</p>
                <p className="text-mutedForeground">
                  {fileDetails.type} · {fileDetails.size}
                </p>
              </div>
              {stage === "done" ? <CheckCircle2 className="h-5 w-5 text-success" /> : null}
            </div>
          </div>
        ) : null}

        <div className="rounded-2xl border border-white/40 bg-white/45 p-4 text-sm text-neutral-600 dark:border-white/10 dark:bg-white/5 dark:text-neutral-400">
          <div className="flex items-center gap-2 font-semibold text-neutral-900 dark:text-white">
            <ShieldCheck className="h-4 w-4 text-success" />
            Upload policy
          </div>
          <ul className="mt-3 space-y-2">
            <li>Private object storage only</li>
            <li>Accepted types: JPEG, PNG, HEIC, PDF</li>
            <li>Large or ambiguous receipts remain human-reviewable</li>
          </ul>
        </div>

        {stage === "done" && createdReceiptId ? (
          <div className="rounded-2xl border border-success/30 bg-success/10 p-4 text-sm">
            <p className="font-semibold text-foreground">Receipt created — processing started</p>
            <p className="mt-2 text-mutedForeground">
              The receipt has been uploaded and background extraction is running. You'll be redirected to its detail page momentarily.
            </p>
            <div className="mt-4 flex flex-wrap gap-3">
              <Link href={`/receipts/${createdReceiptId}`} className={cn(buttonVariants({ variant: "default" }))}>
                View receipt
              </Link>
              <Link href="/receipts" className={cn(buttonVariants({ variant: "secondary" }))}>
                Open receipts inbox
              </Link>
            </div>
          </div>
        ) : null}
      </CardContent>
      <CardFooter>
        <Button onClick={handleUpload} disabled={isUploading}>
          {isUploading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              {STAGE_LABELS[stage]}
            </>
          ) : selectedFile ? (
            stage === "done" ? "Uploaded" : "Upload & Process"
          ) : (
            "Choose File"
          )}
        </Button>
      </CardFooter>
    </Card>
  );
}
