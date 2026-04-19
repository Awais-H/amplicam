import { AuditEvent } from "@/lib/types/entities";

export function AuditTimeline({ events }: { events: AuditEvent[] }) {
  return (
    <div className="space-y-4">
      {events.map((event) => (
        <div key={event.id} className="rounded-2xl border border-border bg-card p-4 shadow-panel">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="font-semibold">{event.eventType}</p>
              <p className="text-sm text-mutedForeground">{event.actorDisplay ?? "System actor"}</p>
            </div>
            <p className="text-xs uppercase tracking-[0.16em] text-mutedForeground">{event.actionSource}</p>
          </div>
          <pre className="mt-4 overflow-x-auto rounded-xl bg-accent/40 p-3 text-xs text-foreground">
            {JSON.stringify(event.after, null, 2)}
          </pre>
        </div>
      ))}
    </div>
  );
}

