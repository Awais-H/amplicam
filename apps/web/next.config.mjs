import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** Repo root (`apps/web` → `apps` → repo) — fixes tracing when a root lockfile exists next to `apps/web`. */
const monorepoRoot = path.join(__dirname, "..", "..");

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  outputFileTracingRoot: monorepoRoot,
  async rewrites() {
    const apiOrigin = (process.env.API_URL ?? "http://localhost:3100").replace(/\/graphql\/?$/, "");
    return [
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
