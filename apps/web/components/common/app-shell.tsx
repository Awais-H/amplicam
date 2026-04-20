"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { FileSearch, LayoutDashboard, ReceiptText, Settings2 } from "lucide-react";

import { AuthToolbar } from "@/components/auth/auth-toolbar";
import { SkyAtmosphere, glassPanel, glassPanelContent } from "@/components/common/sky-atmosphere";
import { cn } from "@/lib/utils";

const navItems = [
  { href: "/receipts", label: "Receipts", icon: ReceiptText },
  { href: "/review", label: "Review", icon: FileSearch },
  { href: "/settings/policies", label: "Policies", icon: Settings2 }
];

function navActive(pathname: string, href: string) {
  if (pathname === href) return true;
  if (href === "/") return false;
  return pathname.startsWith(`${href}/`);
}

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="relative min-h-screen text-foreground">
      <SkyAtmosphere />
      <div className="relative z-10 mx-auto grid min-h-screen max-w-[1440px] gap-6 px-4 py-6 md:py-8 lg:grid-cols-[minmax(0,280px)_1fr]">
        <aside className={cn(glassPanel, "flex h-fit flex-col p-5 md:sticky md:top-8 md:max-h-[calc(100dvh-4rem)] md:overflow-y-auto")}>
          <div className="flex items-center gap-3">
            <div className="rounded-2xl bg-neutral-900 p-3 text-white shadow-md dark:bg-white dark:text-neutral-900">
              <LayoutDashboard className="h-5 w-5" aria-hidden />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">Bookkeeper</p>
              <p className="text-lg font-bold tracking-tight text-neutral-900 dark:text-white">Accounting</p>
            </div>
          </div>

          <nav className="mt-8 space-y-1.5" aria-label="Main navigation">
            {navItems.map(({ href, label, icon: Icon }) => {
              const active = navActive(pathname, href);
              return (
                <Link
                  key={href}
                  href={href}
                  className={cn(
                    "flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-semibold transition-colors",
                    active
                      ? "border border-white/55 bg-white/65 text-neutral-900 shadow-sm dark:border-white/12 dark:bg-white/10 dark:text-white"
                      : "text-neutral-600 hover:bg-white/50 hover:text-neutral-900 dark:text-neutral-400 dark:hover:bg-white/5 dark:hover:text-white"
                  )}
                >
                  <Icon className="h-4 w-4 shrink-0 opacity-80" aria-hidden />
                  {label}
                </Link>
              );
            })}
          </nav>

          <AuthToolbar />
        </aside>

        <main className={cn(glassPanelContent, "min-h-[min(100dvh,880px)] space-y-8 p-5 md:p-8 lg:min-h-[calc(100dvh-4rem)]")}>{children}</main>
      </div>
    </div>
  );
}
