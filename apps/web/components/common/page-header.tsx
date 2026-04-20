import { ReactNode } from "react";

export function PageHeader({
  eyebrow,
  title,
  description,
  actions
}: {
  eyebrow: string;
  title: string;
  description: string;
  actions?: ReactNode;
}) {
  return (
    <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
      <div className="space-y-2">
        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-neutral-500 dark:text-neutral-400">{eyebrow}</p>
        <div className="space-y-1">
          <h1 className="text-2xl font-bold tracking-tight text-neutral-900 md:text-3xl dark:text-white">{title}</h1>
          <p className="max-w-2xl text-sm leading-relaxed text-neutral-600 dark:text-neutral-400">{description}</p>
        </div>
      </div>
      {actions ? <div className="flex shrink-0 flex-wrap gap-2 md:justify-end">{actions}</div> : null}
    </div>
  );
}
