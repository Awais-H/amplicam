import Link from "next/link";
import { FileSearch, LayoutDashboard, ReceiptText, Settings2 } from "lucide-react";

import { cn } from "@/lib/utils";

const navItems = [
  { href: "/receipts", label: "Receipts", icon: ReceiptText },
  { href: "/review", label: "Review", icon: FileSearch },
  { href: "/settings/policies", label: "Policies", icon: Settings2 }
];

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="mx-auto grid min-h-screen max-w-[1440px] gap-6 px-4 py-4 lg:grid-cols-[260px_1fr]">
        <aside className="rounded-[28px] border border-border bg-card/95 p-5 shadow-panel">
          <div className="flex items-center gap-3">
            <div className="rounded-2xl bg-primary p-3 text-primaryForeground">
              <LayoutDashboard className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-mutedForeground">Bookkeeper</p>
              <p className="text-lg font-semibold">Accounting Agent</p>
            </div>
          </div>

          <nav className="mt-8 space-y-2">
            {navItems.map(({ href, label, icon: Icon }) => (
              <Link
                key={href}
                href={href}
                className={cn(
                  "flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-medium text-mutedForeground transition-colors hover:bg-accent hover:text-accentForeground"
                )}
              >
                <Icon className="h-4 w-4" />
                {label}
              </Link>
            ))}
          </nav>

          <div className="mt-8 rounded-2xl bg-accent/60 p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-mutedForeground">Workspace</p>
            <p className="mt-2 text-sm font-semibold">Demo Organization</p>
            <p className="mt-1 text-sm text-mutedForeground">Conservative auto-post disabled by default.</p>
          </div>
        </aside>

        <main className="space-y-6 rounded-[28px] border border-border bg-background/80 p-4 md:p-8">{children}</main>
      </div>
    </div>
  );
}

