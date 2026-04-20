/** Rails API origin for OAuth (must match Google Cloud "Authorized redirect URIs"). */
export function apiOriginForOAuth(): string {
  return (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3100").replace(/\/$/, "");
}
