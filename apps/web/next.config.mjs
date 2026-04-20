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

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  outputFileTracingRoot: monorepoRoot,
  async rewrites() {
    if (process.env.NODE_ENV === "production" && !process.env.API_URL?.trim()) {
      throw new Error(
        "API_URL is unset. Production cannot proxy /graphql or /auth/* without your Rails API origin. " +
          "Add API_URL (e.g. https://your-service.up.railway.app) and redeploy."
      );
    }
    const apiOrigin = normalizeApiOrigin(process.env.API_URL);
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
        source: "/auth/:path*",
        destination: `${apiOrigin}/auth/:path*`
      }
    ];
  }
};

export default nextConfig;
