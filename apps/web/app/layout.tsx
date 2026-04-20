import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Bookkeeper",
    template: "%s · Bookkeeper"
  },
  description: "Receipt intake, extraction, and review for your books."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full font-sans antialiased">{children}</body>
    </html>
  );
}
