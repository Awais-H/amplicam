"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Loader2 } from "lucide-react";

import { SkyAtmosphere, glassPanel } from "@/components/common/sky-atmosphere";
import { clearStoredAuth, getAccessToken } from "@/lib/auth/token-storage";
import { cn } from "@/lib/utils";

/**
 * When enabled (default), (app) routes require a valid JWT: local expiry check plus
 * server verification via GET /auth/me before any dashboard UI is rendered.
 * Set `NEXT_PUBLIC_REQUIRE_AUTH=false` for local development without sign-in.
 */
const requireAuth = process.env.NEXT_PUBLIC_REQUIRE_AUTH !== "false";

async function verifySession(accessToken: string): Promise<boolean> {
  try {
    const res = await fetch("/auth/me", {
      method: "GET",
      credentials: "include",
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    return res.ok;
  } catch {
    return false;
  }
}

export function AuthGate({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!requireAuth) {
      setReady(true);
      return;
    }

    let cancelled = false;

    (async () => {
      const token = getAccessToken();
      const nextParam = encodeURIComponent(`${pathname}${typeof window !== "undefined" ? window.location.search : ""}`);

      if (!token) {
        router.replace(`/login?next=${nextParam}`);
        return;
      }

      const ok = await verifySession(token);
      if (cancelled) return;

      if (ok) {
        setReady(true);
        return;
      }

      clearStoredAuth();
      router.replace(`/login?next=${nextParam}`);
    })();

    return () => {
      cancelled = true;
    };
  }, [pathname, router]);

  if (!requireAuth) {
    return <>{children}</>;
  }

  if (!ready) {
    return (
      <div className="relative min-h-screen overflow-hidden">
        <SkyAtmosphere />
        <div className="relative z-10 flex min-h-screen flex-col items-center justify-center px-4 py-12">
          <div className={cn(glassPanel, "flex w-full max-w-[360px] flex-col items-center gap-4 p-10")}>
            <Loader2 className="h-9 w-9 animate-spin text-neutral-400 dark:text-neutral-500" aria-hidden />
            <div className="text-center">
              <p className="text-sm font-semibold text-neutral-900 dark:text-white">Verifying your session</p>
              <p className="mt-1 text-xs leading-relaxed text-neutral-500 dark:text-neutral-400">
                Please wait while we confirm your sign-in.
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
