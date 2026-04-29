import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** Repo root (`apps/web` → `apps` → repo) — fixes tracing when a root lockfile exists next to `apps/web`. */
const monorepoRoot = path.join(__dirname, "..", "..");

/** Next rewrites require `http://` or `https://`. Bare hostnames from env get https. */
function normalizeApiOrigin(raw) {
  let s = (raw ?? "http://localhost:3100").trim().replace(/\/graphql\/?$/i, "");
  if (!/^https?:\/\//i.test(s)) {
    s = `https://${s.replace(/^\/+/, "")}`;
  }
  return s.replace(/\/+$/, "");
}

function configuredApiOrigin() {
  return process.env.API_URL?.trim() || process.env.NEXT_PUBLIC_API_URL?.trim() || "";
}

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  outputFileTracingRoot: monorepoRoot,
  async rewrites() {
    const configuredOrigin = configuredApiOrigin();
    if (process.env.NODE_ENV === "production" && !configuredOrigin) {
      throw new Error(
        "API_URL or NEXT_PUBLIC_API_URL is unset. Production cannot proxy /graphql or /auth/* without your Rails API origin. " +
          "Add one of them (e.g. https://your-service.up.railway.app) and redeploy."
      );
    }
    const apiOrigin = normalizeApiOrigin(configuredOrigin);
    return [
      {
        source: "/favicon.ico",
        destination: "/favicon.svg"
      },
      {
        source: "/graphql",
        destination: `${apiOrigin}/graphql`
      },
      {
        source: "/storage/:path*",
        destination: `${apiOrigin}/storage/:path*`
      },
      {
        source: "/rails/active_storage/:path*",
        destination: `${apiOrigin}/rails/active_storage/:path*`
      },
      {
        source: "/auth/:path*",
        destination: `${apiOrigin}/auth/:path*`
      }
    ];
  }
};

export default nextConfig;
