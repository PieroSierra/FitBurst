"use client";

import { useEffect, useRef } from "react";
import type { ReactNode } from "react";

/* Publishes a 0 → 1 scroll-in progress on `--p` of its own element, so child
 * CSS can scrub a reveal. Progress = how far the wrapper has entered from the
 * bottom (clamp((viewportH − top) / height)): 0 as its top touches the bottom
 * edge, 1 once a full height has passed. Holds at 1 when scrolled past, unwinds
 * symmetrically on the way back up. Reduced motion pins it to the final state.
 * Same feel as the hero fan, minus the fan-specific geometry. */
export default function ScrollReveal({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    let p = -1;
    const set = (v: number) => {
      if (v === p) return;
      p = v;
      el.style.setProperty("--p", String(v));
    };

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      set(1);
      return;
    }

    const compute = () => {
      const r = el.getBoundingClientRect();
      const vh = window.innerHeight || document.documentElement.clientHeight;
      const frac = (vh - r.top) / r.height;
      set(frac < 0 ? 0 : frac > 1 ? 1 : frac);
    };

    let ticking = false;
    const onScroll = () => {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        ticking = false;
        compute();
      });
    };

    compute();
    window.addEventListener("scroll", onScroll, { passive: true });
    const ro = new ResizeObserver(compute);
    ro.observe(el);

    return () => {
      window.removeEventListener("scroll", onScroll);
      ro.disconnect();
    };
  }, []);

  return (
    <div ref={ref} className={className}>
      {children}
    </div>
  );
}
