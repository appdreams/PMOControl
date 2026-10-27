import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // Lets local dev instances avoid colliding with a stale or concurrently held .next lock.
  distDir: process.env.NEXT_DIST_DIR ?? ".next",
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
