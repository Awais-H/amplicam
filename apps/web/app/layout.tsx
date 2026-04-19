import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: "Bookkeeper Agent",
  description: "Receipt-first bookkeeping workflow UI"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

