/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  async rewrites() {
    const apiOrigin = (process.env.API_URL ?? "http://localhost:3100").replace(/\/graphql\/?$/, "");
    return [
      {
        source: "/graphql",
        destination: `${apiOrigin}/graphql`,
      },
      {
        source: "/auth/:path*",
        destination: `${apiOrigin}/auth/:path*`,
      },
    ];
  },
};

export default nextConfig;

