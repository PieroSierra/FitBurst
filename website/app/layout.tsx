import type { Metadata, Viewport } from "next";
import { fontVars } from "./fonts";
import "./fitburst.css";

// Vercel sets VERCEL_PROJECT_PRODUCTION_URL to the production domain (the
// custom domain once one is added, otherwise fit-burst.vercel.app), so link
// previews always point at a domain that serves the image.
const SITE_URL = process.env.VERCEL_PROJECT_PRODUCTION_URL
  ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
  : "http://localhost:3100";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: "FitBurst: workout tracker for iPhone",
  description:
    "Track your workouts in style. Customize your workouts and wallpaper, earn trophies for perfect streaks, and stay motivated with widgets. Free on the App Store.",
  icons: {
    icon: [
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
    ],
    apple: { url: "/apple-touch-icon.png", sizes: "180x180" },
  },
  openGraph: {
    type: "website",
    siteName: "FitBurst",
    title: "FitBurst: track your workouts in style",
    description:
      "A workout tracker with bold design, 3D trophies for perfect streaks, and a wallpaper you pick. Free on the App Store.",
    url: "/",
    images: [
      {
        url: "/og-image.jpg",
        width: 1200,
        height: 630,
        alt: "FitBurst on an iPhone, showing 222 workouts and a row of trophies",
      },
    ],
  },
  twitter: { card: "summary_large_image" },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#000000",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={fontVars}>{children}</body>
    </html>
  );
}
