/** Rails API origin for OAuth (must match Google Cloud "Authorized redirect URIs"). */
export function apiOriginForOAuth(): string {
  let s = (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3100").trim();
  if (!/^https?:\/\//i.test(s)) {
    s = `https://${s.replace(/^\/+/, "")}`;
  }
  return s.replace(/\/+$/, "");
}
