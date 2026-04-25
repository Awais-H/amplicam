"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";
import { Eye, EyeOff, Lock, Mail, User } from "lucide-react";

import { SkyAtmosphere } from "@/components/common/sky-atmosphere";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { clearStoredAuth, setStoredAuth } from "@/lib/auth/token-storage";

function safeNextPath(): string {
  if (typeof window === "undefined") return "/receipts";
  const raw = new URLSearchParams(window.location.search).get("next");
  if (!raw || !raw.startsWith("/") || raw.startsWith("//")) return "/receipts";
  return raw;
}

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [mode, setMode] = useState<"login" | "register">("login");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const err = params.get("auth_error");
    if (err) setError(err);
  }, []);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const path = mode === "login" ? "/auth/login" : "/auth/register";
      const body =
        mode === "login"
          ? { email, password }
          : { email, password, password_confirmation: password, display_name: displayName || undefined };
      const res = await fetch(path, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify(body)
      });
      const data = (await res.json()) as { access_token?: string; expires_in?: number; error?: string; details?: string[] };
      if (!res.ok) {
        const msg = data.details?.length ? data.details.join(", ") : data.error ?? "Request failed";
        throw new Error(msg);
      }
      if (data.access_token && data.expires_in) {
        setStoredAuth(data.access_token, data.expires_in);
        router.replace(safeNextPath());
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  const fieldShell =
    "h-12 w-full rounded-xl border-0 bg-neutral-100/90 pl-11 pr-11 text-sm text-neutral-900 shadow-inner placeholder:text-neutral-400 focus-visible:ring-2 focus-visible:ring-sky-400/50 dark:bg-white/10 dark:text-white dark:placeholder:text-neutral-500";

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden px-4 py-12">
      <SkyAtmosphere />

      <div
        className={cn(
          "relative z-10 w-full max-w-[420px] rounded-[28px] border border-white/60 bg-white/75 p-8 shadow-[0_24px_80px_-12px_rgba(15,23,42,0.18)] backdrop-blur-xl",
          "dark:border-white/15 dark:bg-slate-900/70 dark:shadow-[0_24px_80px_-12px_rgba(0,0,0,0.45)]"
        )}
      >
        <div className="flex flex-col items-center text-center">
          <h1 className="text-2xl font-bold tracking-tight text-neutral-900 dark:text-white">
            {mode === "login" ? "Sign in with email" : "Create your account"}
          </h1>
          <p className="mt-2 max-w-[320px] text-sm leading-relaxed text-neutral-500 dark:text-neutral-400">
            {mode === "login"
              ? "Bring receipts, approvals, and your books together. Sign in to continue."
              : "Create a workspace and start uploading receipts in a few seconds."}
          </p>
        </div>

        <form className="mt-8 space-y-4" onSubmit={submit}>
          {error ? (
            <p className="rounded-xl bg-red-50 px-3 py-2 text-center text-sm text-red-700 dark:bg-red-950/40 dark:text-red-300">
              {error}
            </p>
          ) : null}

          {mode === "register" ? (
            <div className="relative">
              <span className="pointer-events-none absolute left-3.5 top-1/2 z-[1] -translate-y-1/2 text-neutral-400 dark:text-neutral-500">
                <User className="h-4 w-4" aria-hidden />
              </span>
              <Input
                id="displayName"
                className={fieldShell}
                placeholder="Display name (optional)"
                value={displayName}
                onChange={(ev) => setDisplayName(ev.target.value)}
                autoComplete="name"
              />
            </div>
          ) : null}

          <div className="relative">
            <span className="pointer-events-none absolute left-3.5 top-1/2 z-[1] -translate-y-1/2 text-neutral-400 dark:text-neutral-500">
              <Mail className="h-4 w-4" aria-hidden />
            </span>
            <Input
              id="email"
              type="email"
              className={fieldShell}
              placeholder="Email"
              required
              value={email}
              onChange={(ev) => setEmail(ev.target.value)}
              autoComplete="email"
              aria-label="Email"
            />
          </div>

          <div className="relative">
            <span className="pointer-events-none absolute left-3.5 top-1/2 z-[1] -translate-y-1/2 text-neutral-400 dark:text-neutral-500">
              <Lock className="h-4 w-4" aria-hidden />
            </span>
            <Input
              id="password"
              type={showPassword ? "text" : "password"}
              className={cn(fieldShell, "pr-12")}
              placeholder="Password"
              required
              minLength={8}
              value={password}
              onChange={(ev) => setPassword(ev.target.value)}
              autoComplete={mode === "login" ? "current-password" : "new-password"}
              aria-label="Password"
            />
            <button
              type="button"
              className="absolute right-2 top-1/2 z-[1] -translate-y-1/2 rounded-lg p-2 text-neutral-400 transition hover:bg-neutral-200/80 hover:text-neutral-700 dark:hover:bg-white/10 dark:hover:text-neutral-200"
              onClick={() => setShowPassword((v) => !v)}
              aria-label={showPassword ? "Hide password" : "Show password"}
            >
              {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
            </button>
          </div>

          {mode === "login" ? (
            <div className="text-right">
              <span className="text-sm text-neutral-500 dark:text-neutral-400">Forgot password? </span>
              <span className="text-sm text-neutral-400 dark:text-neutral-500">Contact your admin for now.</span>
            </div>
          ) : (
            <div className="h-5" aria-hidden />
          )}

          <Button
            type="submit"
            disabled={loading}
            className="h-12 w-full rounded-xl bg-neutral-900 text-[15px] font-semibold text-white shadow-md transition hover:bg-neutral-800 dark:bg-white dark:text-neutral-900 dark:hover:bg-neutral-100"
          >
            {loading ? "Please wait…" : mode === "login" ? "Get Started" : "Create account"}
          </Button>
        </form>

        <p className="mt-6 text-center text-sm text-neutral-500 dark:text-neutral-400">
          {mode === "login" ? (
            <>
              Need an account?{" "}
              <button type="button" className="font-semibold text-neutral-900 underline dark:text-white" onClick={() => setMode("register")}>
                Create one
              </button>
            </>
          ) : (
            <>
              Already registered?{" "}
              <button type="button" className="font-semibold text-neutral-900 underline dark:text-white" onClick={() => setMode("login")}>
                Sign in
              </button>
            </>
          )}
        </p>

        <div className="mt-6 flex flex-col gap-2 border-t border-neutral-200/80 pt-6 dark:border-white/10">
          <button
            type="button"
            className="text-center text-xs text-neutral-400 underline-offset-2 hover:underline dark:text-neutral-500"
            onClick={() => clearStoredAuth()}
          >
            Clear saved session token
          </button>
          {process.env.NEXT_PUBLIC_REQUIRE_AUTH === "false" ? (
            <Link href="/receipts" className="text-center text-sm font-medium text-sky-700 hover:underline dark:text-sky-400">
              Continue without signing in (dev only)
            </Link>
          ) : null}
        </div>
      </div>
    </div>
  );
}
