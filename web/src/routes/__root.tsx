import { createRootRoute, HeadContent, Outlet, Scripts } from "@tanstack/react-router";
import appCss from "../styles.css?url";

const DESCRIPTION = "Little lights. Big little adventures. A soft night companion.";
// Absolute share-card URLs need the final public address. Set VITE_SITE_URL when it is decided.
const SITE_URL = String(import.meta.env.VITE_SITE_URL ?? "").replace(/\/+$/, "");

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "Lummings" },
      { name: "description", content: DESCRIPTION },
      { name: "theme-color", content: "#0b1022" },
      { name: "mobile-web-app-capable", content: "yes" },
      { name: "apple-mobile-web-app-capable", content: "yes" },
      { name: "apple-mobile-web-app-title", content: "Lummings" },
      { property: "og:type", content: "website" },
      { property: "og:title", content: "Lummings" },
      { property: "og:description", content: DESCRIPTION },
      ...(SITE_URL
        ? [
            { property: "og:url", content: SITE_URL },
            { property: "og:image", content: `${SITE_URL}/og.jpg` },
            { name: "twitter:card", content: "summary_large_image" },
          ]
        : [{ name: "twitter:card", content: "summary" }]),
    ],
    links: [
      { rel: "icon", type: "image/svg+xml", href: "/favicon.svg" },
      { rel: "stylesheet", href: appCss },
      { rel: "manifest", href: "/manifest.webmanifest" },
      { rel: "apple-touch-icon", href: "/icons/apple-touch-icon.png" },
    ],
  }),
  component: () => (
    <html lang="en" suppressHydrationWarning>
      <head>
        <HeadContent />
      </head>
      <body>
        <Outlet />
        <Scripts />
      </body>
    </html>
  ),
});
