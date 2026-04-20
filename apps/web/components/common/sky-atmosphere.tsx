import { cn } from "@/lib/utils";

/** Full-viewport background matching the login screen (gradient, clouds, rings). */
export function SkyAtmosphere({ className }: { className?: string }) {
  return (
    <div className={cn("pointer-events-none absolute inset-0 overflow-hidden", className)} aria-hidden>
      <div className="absolute inset-0 bg-gradient-to-b from-sky-200 via-sky-100 to-blue-50 dark:from-slate-950 dark:via-slate-900 dark:to-slate-950" />
      <div className="absolute -left-24 top-20 h-72 w-96 rounded-full bg-white/50 blur-3xl dark:bg-sky-500/10" />
      <div className="absolute -right-16 bottom-24 h-80 w-80 rounded-full bg-white/40 blur-3xl dark:bg-blue-500/10" />
      <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
        <div className="absolute left-1/2 top-1/2 h-[min(90vw,720px)] w-[min(90vw,720px)] -translate-x-1/2 -translate-y-1/2 rounded-full border border-white/35 dark:border-white/10" />
        <div className="absolute left-1/2 top-1/2 h-[min(70vw,520px)] w-[min(70vw,520px)] -translate-x-1/2 -translate-y-1/2 rounded-full border border-white/25 dark:border-white/10" />
        <div className="absolute left-1/2 top-1/2 h-[min(50vw,360px)] w-[min(50vw,360px)] -translate-x-1/2 -translate-y-1/2 rounded-full border border-white/20 dark:border-white/10" />
      </div>
    </div>
  );
}

/** Primary glass panel — same recipe as the login card. */
export const glassPanel =
  "rounded-[28px] border border-white/60 bg-white/75 shadow-[0_24px_80px_-12px_rgba(15,23,42,0.18)] backdrop-blur-xl dark:border-white/15 dark:bg-slate-900/70 dark:shadow-[0_24px_80px_-12px_rgba(0,0,0,0.45)]";

/** Main content column — slightly more opaque for long-form readability. */
export const glassPanelContent =
  "rounded-[28px] border border-white/55 bg-white/82 shadow-[0_20px_64px_-18px_rgba(15,23,42,0.14)] backdrop-blur-xl dark:border-white/12 dark:bg-slate-900/75 dark:shadow-[0_20px_64px_-18px_rgba(0,0,0,0.4)]";
