import * as React from "react";

import { cn } from "@/lib/utils";

export function Sheet({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}

export function SheetContent({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <aside className={cn("rounded-2xl border border-border bg-card p-6 shadow-panel", className)} {...props} />;
}

