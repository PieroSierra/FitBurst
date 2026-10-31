"use client";

import dynamic from "next/dynamic";
import { useEffect, useRef, useState } from "react";

const AwardsOrbit = dynamic(() => import("./AwardsOrbit"), { ssr: false });

/* Holds the orbit's space and mounts the three.js scene only once the section
 * is within a screen of the viewport, so first paint never waits on the 3D
 * bundle or the award models. */
export default function AwardsOrbitLazy() {
  const ref = useRef<HTMLDivElement>(null);
  const [near, setNear] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setNear(true);
          io.disconnect();
        }
      },
      { rootMargin: "100% 0px" },
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  return (
    <div ref={ref} className="fb-orbit-slot">
      {near && <AwardsOrbit />}
    </div>
  );
}
