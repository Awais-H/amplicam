import * as React from "react";

import { cn } from "@/lib/utils";

export function DropdownMenu({ children }: { children: React.ReactNode }) {
  return <div className="relative inline-flex">{children}</div>;
}

export function DropdownMenuTrigger({ className, ...props }: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  return <button className={cn("rounded-xl border border-border px-3 py-2 text-sm text-mutedForeground hover:bg-accent", className)} {...props} />;
}

export function DropdownMenuContent({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("absolute right-0 top-full z-10 mt-2 min-w-40 rounded-xl border border-border bg-card p-2 shadow-panel", className)} {...props} />;
}

export function DropdownMenuItem({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("rounded-lg px-3 py-2 text-sm text-foreground hover:bg-accent", className)} {...props} />;
}

