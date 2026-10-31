/**
 * FitBurst's type, self-hosted through next/font.
 *
 * Headlines use Futura, the app's own face, which ships on Apple platforms.
 * Jost is the loaded fallback elsewhere: a geometric sans drawn after Futura.
 * Body text uses Avenir Next Condensed on Apple platforms, with Barlow Semi
 * Condensed as the fallback. Neither fallback is preloaded, since most
 * visitors to an iOS app's page render the system faces.
 */

import { Barlow_Semi_Condensed, Jost } from "next/font/google";

const jost = Jost({
  subsets: ["latin"],
  weight: ["500", "700", "800"],
  variable: "--font-jost",
  display: "swap",
  preload: false,
});

const barlow = Barlow_Semi_Condensed({
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  variable: "--font-barlow",
  display: "swap",
  preload: false,
});

export const fontVars = `${jost.variable} ${barlow.variable}`;
