/** Rails API origin for OAuth (must match Google Cloud "Authorized redirect URIs"). */
export function apiOriginForOAuth(): string {
  const raw = process.env.NEXT_PUBLIC_API_URL?.trim();
  if (process.env.NODE_ENV === "production" && !raw) {
    throw new Error("NEXT_PUBLIC_API_URL is required in production.");
  }
  let s = (raw ?? "http://localhost:3100").trim();
  if (!/^https?:\/\//i.test(s)) {
    s = `https://${s.replace(/^\/+/, "")}`;
  }
  return s.replace(/\/+$/, "");
}
