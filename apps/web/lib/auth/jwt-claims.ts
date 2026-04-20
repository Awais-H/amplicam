/** Read JWT payload (unverified) for UI labels only. */
export function parseJwtPayload(token: string): { sub?: string; email?: string; name?: string; exp?: number } | null {
  try {
    const part = token.split(".")[1];
    if (!part) return null;
    const padded = part.replace(/-/g, "+").replace(/_/g, "/");
    const json = atob(padded);
    return JSON.parse(json) as { sub?: string; email?: string; name?: string; exp?: number };
  } catch {
    return null;
  }
}
