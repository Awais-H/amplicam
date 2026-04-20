"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { LogOut, UserRound } from "lucide-react";

import { Button, buttonVariants } from "@/components/ui/button";
import { AUTH_STORAGE_KEY, getAccessToken, clearStoredAuth } from "@/lib/auth/token-storage";
import { parseJwtPayload } from "@/lib/auth/jwt-claims";
import { isProductionBuild } from "@/lib/env-public";
import { cn } from "@/lib/utils";

const requireAuth = process.env.NEXT_PUBLIC_REQUIRE_AUTH !== "false";

function readLabelFromToken(): string | null {
  if (typeof window === "undefined") return null;
  const token = getAccessToken();
  if (!token) return null;
  const claims = parseJwtPayload(token);
  return claims?.email ?? claims?.name ?? "Signed in";
}

const panelClass =
  "mt-8 space-y-3 rounded-2xl border border-white/50 bg-white/45 p-4 dark:border-white/10 dark:bg-white/5";

export function AuthToolbar() {
  const router = useRouter();
  const [label, setLabel] = useState<string | null>(() => readLabelFromToken());

  const refresh = useCallback(() => {
    setLabel(readLabelFromToken());
  }, []);

  useEffect(() => {
    refresh();
    const onStorage = (e: StorageEvent) => {
      if (e.key === AUTH_STORAGE_KEY || e.key === null) refresh();
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, [refresh]);

  async function logout() {
    const token = getAccessToken();
    try {
      await fetch("/auth/logout", {
        method: "DELETE",
        credentials: "include",
        headers: token ? { Authorization: `Bearer ${token}` } : undefined
      });
    } catch {
      /* ignore */
    }
    clearStoredAuth();
    setLabel(null);
    router.replace("/login");
    router.refresh();
  }

  if (!requireAuth) {
    return (
      <div className={cn(panelClass, "border-dashed")}>
        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">Account</p>
        <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-400">
          Authentication is optional in this environment.
        </p>
        <Link href="/login" className={cn(buttonVariants({ variant: "secondary", size: "sm" }), "w-full justify-center")}>
          Sign in
        </Link>
      </div>
    );
  }

  if (!getAccessToken()) {
    return (
      <div className={panelClass}>
        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">Account</p>
        <p className="text-sm text-neutral-600 dark:text-neutral-400">You are not signed in.</p>
        <Link href="/login" className={cn(buttonVariants({ size: "sm" }), "w-full justify-center")}>
          Sign in
        </Link>
      </div>
    );
  }

  return (
    <div className={panelClass}>
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">Signed in</p>
      <div className="flex items-start gap-2">
        <UserRound className="mt-0.5 h-4 w-4 shrink-0 text-neutral-400 dark:text-neutral-500" aria-hidden />
        <p className="break-all text-sm font-semibold leading-snug text-neutral-900 dark:text-white">{label ?? "…"}</p>
      </div>
      {!isProductionBuild ? (
        <p className="text-xs leading-relaxed text-neutral-500 dark:text-neutral-400">
          Session token is stored in this browser for API requests.
        </p>
      ) : null}
      <Button
        type="button"
        variant="secondary"
        size="sm"
        className="w-full gap-2 border-neutral-200/80 bg-white/70 hover:bg-white dark:border-white/10 dark:bg-white/10 dark:hover:bg-white/15"
        onClick={() => void logout()}
      >
        <LogOut className="h-4 w-4" aria-hidden />
        Log out
      </Button>
    </div>
  );
}
