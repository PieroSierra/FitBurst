"use client";

import Image from "next/image";
import { useEffect, useRef } from "react";
import type { CSSProperties } from "react";

/* The five hero phones, from the left edge inward. `rot`/`y` are the fully
 * "open" splay: a shallow arc with the home screen upright in the centre.
 * At open = 0 every card collapses onto the centre (upright, top-aligned) for
 * a closed deck; the component scrubs between the two on scroll. The outer
 * four show the same home screen over different wallpapers. */
const FAN = [
  { src: "wall-aurora.jpg", alt: "FitBurst over an aurora wallpaper", cls: "fb-fan-outer", rot: -11, y: 130 },
  { src: "wall-mountain.jpg", alt: "FitBurst over a mountain wallpaper", cls: "fb-fan-inner", rot: -5, y: 60 },
  { src: "hero.jpg", alt: "FitBurst home screen counting 222 workouts", cls: "fb-fan-centre", rot: 0, y: 0 },
  { src: "wall-jungle.jpg", alt: "FitBurst over a jungle wallpaper", cls: "fb-fan-inner", rot: 5, y: 60 },
  { src: "wall-palm.jpg", alt: "FitBurst over a sunset palm wallpaper", cls: "fb-fan-outer", rot: 11, y: 130 },
];

const SHOT_W = 820;
const SHOT_H = 1783;

/* The widest a phone renders is .fb-fan-centre at clamp(168px, 26vw, 270px);
 * the frame overlay is 232% of that. */
const FAN_SIZES = "(max-width: 900px) 45vw, 270px";
const FRAME_SIZES = "(max-width: 900px) 105vw, 630px";

// The count-up plays once each time the fan reaches fully open, and rewinds
// once the fan has mostly closed again, so scrolling back down replays it.
const PLAY_AT = 0.98;
const REWIND_BELOW = 0.5;

export default function HeroFan({ video }: { video: string }) {
  const fanRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const fan = fanRef.current;
    if (!fan) return;

    const phones = Array.from(fan.querySelectorAll<HTMLElement>(".fb-fan-phone"));

    // Per-card horizontal distance to the fan's centre, measured from the
    // untransformed flex layout (offsetLeft ignores transforms).
    const measure = () => {
      const mid = fan.clientWidth / 2;
      for (const p of phones) {
        const cx = mid - (p.offsetLeft + p.offsetWidth / 2);
        p.style.setProperty("--cx", `${cx}px`);
      }
    };

    let open = -1;
    let played = false;
    const apply = (v: number) => {
      if (v === open) return;
      open = v;
      fan.style.setProperty("--open", String(v));
      const vid = videoRef.current;
      if (!vid) return;
      if (v >= PLAY_AT && !played) {
        played = true;
        vid.currentTime = 0;
        vid.play().then(() => vid.classList.add("is-playing")).catch(() => {});
      } else if (v < REWIND_BELOW && played) {
        played = false;
        vid.pause();
        vid.classList.remove("is-playing");
      }
    };

    // Reduced motion: skip the scrub and the count-up, present the still.
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      measure();
      fan.style.setProperty("--open", "1");
      return;
    }

    // Openness = how far the fan has scrolled up into the viewport: 0 as its
    // top touches the bottom edge, 1 once a full fan-height has passed.
    const compute = () => {
      const r = fan.getBoundingClientRect();
      const vh = window.innerHeight || document.documentElement.clientHeight;
      const frac = (vh - r.top) / r.height;
      apply(frac < 0 ? 0 : frac > 1 ? 1 : frac);
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

    measure();
    compute();

    window.addEventListener("scroll", onScroll, { passive: true });
    const ro = new ResizeObserver(() => {
      measure();
      compute();
    });
    ro.observe(fan);

    return () => {
      window.removeEventListener("scroll", onScroll);
      ro.disconnect();
    };
  }, [video]);

  return (
    <div className="fb-fan" ref={fanRef}>
      {FAN.map((p) => {
        const centre = p.cls === "fb-fan-centre";
        return (
          <div
            key={p.src}
            className={`fb-fan-phone ${p.cls}`}
            style={{ "--rot": `${p.rot}deg`, "--ty": `${p.y}px` } as CSSProperties}
          >
            <Image
              className="fb-shot"
              src={`/shots/${p.src}`}
              alt={p.alt}
              width={SHOT_W}
              height={SHOT_H}
              sizes={FAN_SIZES}
              priority={centre}
            />
            {centre && (
              // Hidden until it plays, so its first frame (the digits mid-flight)
              // never covers the still behind. The still is the video's last
              // frame, so the video ends on the same picture.
              <video
                ref={videoRef}
                className="fb-fan-video"
                src={video}
                muted
                playsInline
                preload="metadata"
                aria-hidden="true"
              />
            )}
            <Image
              className="fb-frame"
              src="/iphone_frame.png"
              alt=""
              width={760}
              height={950}
              sizes={FRAME_SIZES}
              priority={centre}
            />
          </div>
        );
      })}
    </div>
  );
}
