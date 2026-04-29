"use client";

import SparkMD5 from "spark-md5";
import { useCallback, useState } from "react";

import { fetchGraphql } from "@/lib/graphql/client";
import { CREATE_RECEIPT, INITIATE_RECEIPT_UPLOAD } from "@/lib/graphql/mutations";

type UploadStage = "idle" | "selected" | "hashing" | "initiating" | "uploading" | "creating" | "done";

interface InitiateResponse {
  initiateReceiptUpload: {
    blobSignedId: string;
    uploadUrl: string;
    headers: Record<string, string>;
  };
}

interface CreateResponse {
  createReceipt: {
    receipt: { id: string; status: string; createdAt: string };
  };
}

function normalizeApiOrigin(raw?: string): string | null {
  const value = raw?.trim();
  if (!value) return null;

  let normalized = value.replace(/\/graphql\/?$/i, "");
  if (!/^https?:\/\//i.test(normalized)) {
    normalized = `https://${normalized.replace(/^\/+/, "")}`;
  }
  return normalized.replace(/\/+$/, "");
}

function uploadTargets(uploadUrl: string): string[] {
  if (!uploadUrl.startsWith("/")) return [uploadUrl];

  const apiOrigin = normalizeApiOrigin(process.env.NEXT_PUBLIC_API_URL);
  if (!apiOrigin) return [uploadUrl];

  return [uploadUrl, `${apiOrigin}${uploadUrl}`];
}

function computeMd5Base64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunkSize = 2 * 1024 * 1024;
    const spark = new SparkMD5.ArrayBuffer();
    const reader = new FileReader();
    let offset = 0;

    reader.onload = (event) => {
      spark.append(event.target?.result as ArrayBuffer);
      offset += chunkSize;
      if (offset < file.size) {
        readNextChunk();
      } else {
        resolve(btoa(spark.end(true)));
      }
    };
    reader.onerror = () => reject(new Error("Failed to read file"));

    function readNextChunk() {
      reader.readAsArrayBuffer(file.slice(offset, offset + chunkSize));
    }
    readNextChunk();
  });
}

export function useReceiptUpload() {
  const [stage, setStage] = useState<UploadStage>("idle");
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [createdReceiptId, setCreatedReceiptId] = useState<string | null>(null);

  const upload = useCallback(async (file: File) => {
    try {
      setError(null);
      setCreatedReceiptId(null);

      setStage("hashing");
      setProgress(10);
      const checksum = await computeMd5Base64(file);
      setProgress(20);

      setStage("initiating");
      setProgress(30);
      const initData = await fetchGraphql<InitiateResponse>(INITIATE_RECEIPT_UPLOAD, {
        filename: file.name,
        byteSize: file.size,
        checksum,
        contentType: file.type || "application/octet-stream",
      });
      setProgress(45);

      const { blobSignedId, uploadUrl, headers } = initData.initiateReceiptUpload;

      setStage("uploading");
      setProgress(50);
      let uploadResponse: Response | null = null;
      let lastError: Error | null = null;

      for (const target of uploadTargets(uploadUrl)) {
        try {
          uploadResponse = await fetch(target, {
            method: "PUT",
            headers: { ...headers, "Content-Type": file.type || "application/octet-stream" },
            body: file,
          });

          if (uploadResponse.ok) break;
        } catch (error) {
          lastError = error instanceof Error ? error : new Error("Direct upload failed");
        }
      }

      if (!uploadResponse && lastError) {
        throw lastError;
      }
      if (!uploadResponse) {
        throw new Error("Direct upload failed");
      }

      if (!uploadResponse.ok) {
        const detail = (await uploadResponse.text()).trim().slice(0, 200);
        throw new Error(
          detail ? `Direct upload failed (${uploadResponse.status}): ${detail}` : `Direct upload failed: ${uploadResponse.status}`
        );
      }
      setProgress(75);

      setStage("creating");
      setProgress(85);
      const createData = await fetchGraphql<CreateResponse>(CREATE_RECEIPT, {
        blobSignedId,
        source: "web_upload",
      });
      setProgress(100);

      setCreatedReceiptId(createData.createReceipt.receipt.id);
      setStage("done");

      return createData.createReceipt.receipt.id;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upload failed");
      setStage("idle");
      setProgress(0);
      return null;
    }
  }, []);

  const reset = useCallback(() => {
    setStage("idle");
    setProgress(0);
    setError(null);
    setCreatedReceiptId(null);
  }, []);

  return { stage, progress, error, createdReceiptId, upload, reset };
}
