import Image from "next/image";
import HeroFan from "./HeroFan";
import ScrollReveal from "./ScrollReveal";
import AwardsOrbitLazy from "./AwardsOrbitLazy";
import { APP_STORE_URL, CONTACT_EMAIL } from "./appStore";

const NAV = [
  ["Tracking", "#tracking"],
  ["Customize", "#customize"],
  ["Trophies", "#trophies"],
  ["Videos", "#videos"],
  ["Widgets", "#widgets"],
] as const;

/* Every screenshot is 1206 × 2622 at source, scaled to 820 wide. */
const SHOT_W = 820;
const SHOT_H = 1783;
const SHOT_SIZES = "(max-width: 700px) 50vw, 240px";
const FRAME_SIZES = "(max-width: 700px) 100vw, 550px";

const WALLPAPERS = [
  { src: "wall-prairie.jpg", alt: "FitBurst over a prairie and mountain wallpaper" },
  { src: "wall-palm.jpg", alt: "FitBurst over a sunset palm wallpaper" },
  { src: "wall-aurora.jpg", alt: "FitBurst over an aurora wallpaper" },
  { src: "wall-jungle.jpg", alt: "FitBurst over a jungle wallpaper" },
  { src: "wall-mountain.jpg", alt: "FitBurst over a black and white mountain wallpaper" },
];

const external = { target: "_blank", rel: "noopener noreferrer" };
const contactHref = `mailto:${CONTACT_EMAIL}?subject=FitBurst`;

function Phone({ src, alt, video }: { src: string; alt: string; video?: string }) {
  return (
    <div className="fb-phone">
      {video ? (
        <video
          className="fb-shot"
          poster={`/shots/${src}`}
          src={`/shots/${video}`}
          aria-label={alt}
          autoPlay
          muted
          loop
          playsInline
        />
      ) : (
        <Image
          className="fb-shot"
          src={`/shots/${src}`}
          alt={alt}
          width={SHOT_W}
          height={SHOT_H}
          sizes={SHOT_SIZES}
        />
      )}
      <Image
        className="fb-frame"
        src="/iphone_frame.png"
        alt=""
        width={760}
        height={950}
        sizes={FRAME_SIZES}
      />
    </div>
  );
}

function AppleLogo() {
  return (
    <svg viewBox="0 0 384 512" className="fb-apple" aria-hidden="true">
      <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z" />
    </svg>
  );
}

function StoreButton({ className }: { className: string }) {
  return (
    <a className={`fb-cta ${className}`} href={APP_STORE_URL} {...external}>
      <AppleLogo />
      <span>Download on the App Store</span>
    </a>
  );
}

export default function Home() {
  return (
    <div className="fb">
      <header className="fb-header">
        <a className="fb-brand" href="#top">
          <Image src="/logo.png" alt="" width={64} height={64} className="fb-mark" priority />
          <span className="fb-wordmark">FitBurst</span>
        </a>
        <nav className="fb-cond fb-nav">
          {NAV.map(([label, href]) => (
            <a key={href} href={href}>
              {label}
            </a>
          ))}
        </nav>
        <a className="fb-cta fb-cta--nav" href={APP_STORE_URL} {...external}>
          Get the app
        </a>
      </header>

      <main id="top">
        {/* Hero */}
        <section className="fb-hero">
          <p className="fb-cond fb-eyebrow">Workout tracker for iPhone and iPad</p>
          <h1 className="fb-h1">Track your workouts in style.</h1>
          <p className="fb-cond fb-lead fb-lead--hero">
            Bold design and smart encouragement. FitBurst cheers on every workout with
            delightful animations, and you get to customize the whole look.
          </p>
          <div className="fb-hero-actions">
            <StoreButton className="fb-cta--hero" />
            <p className="fb-cond fb-hero-note">Free. No ads, no accounts, no tracking.</p>
          </div>
          <HeroFan video="/shots/hero.mp4" />
        </section>

        {/* Tracking */}
        <section id="tracking" className="fb-section fb-split">
          <div>
            <h2 className="fb-h2">Every workout counts. Literally.</h2>
            <p className="fb-cond fb-lead">
              Finish a workout, tap Record, and watch your total climb. The calendar
              fills in a green check for every day you trained, so a whole year of
              effort fits on one screen.
            </p>
          </div>
          <ScrollReveal className="fb-pair">
            <div className="fb-pair-back">
              <Phone src="calendar.jpg" alt="The calendar, with a green check on every workout day of 2025" />
            </div>
            <div className="fb-pair-front">
              <Phone src="hero.jpg" alt="The home screen, counting 222 workouts" />
            </div>
          </ScrollReveal>
        </section>

        {/* Customize */}
        <section id="customize" className="fb-section fb-section--face">
          <div className="fb-split fb-split--top">
            <div>
              <h2 className="fb-h2">Customize your workouts and wallpaper.</h2>
              <p className="fb-cond fb-lead">
                Rename and pick icons for up to six workout types, or switch off the
                ones you never do. Then choose a wallpaper: mountains, jungle, aurora,
                sunset palms, and plenty more.
              </p>
            </div>
            <div className="fb-settings">
              <Phone src="settings.jpg" alt="Settings, listing six workout types with toggles" />
            </div>
          </div>
          <ScrollReveal className="fb-strip">
            <div className="fb-strip-track">
              {WALLPAPERS.map((w) => (
                <div key={w.src} className="fb-strip-item">
                  <Phone src={w.src} alt={w.alt} />
                </div>
              ))}
            </div>
          </ScrollReveal>
        </section>

        {/* Trophies */}
        <section id="trophies" className="fb-section fb-section--trophies">
          <div className="fb-trophies-head">
            <h2 className="fb-h2 fb-h2--big">Earn trophies for perfect streaks.</h2>
            <p className="fb-cond fb-lead">
              Coins for workouts in a row. Gems for perfect weeks. Each one spins onto
              your screen in 3D the moment you earn it.
            </p>
          </div>
          <AwardsOrbitLazy />
          <div className="fb-grid fb-grid--trophies">
            <div>
              <Phone
                src="award-unlock-poster.jpg"
                video="award-unlock.mp4"
                alt="A gold coin award spinning in after ten workouts in a row"
              />
              <div className="fb-caption">
                <h3 className="fb-title">Unlocked in the moment</h3>
                <p className="fb-cond fb-body">
                  Hit ten in a row and a gold coin flips onto your home screen.
                </p>
              </div>
            </div>
            <div>
              <Phone
                src="trophies-poster.jpg"
                video="trophies.mp4"
                alt="The trophy cabinet, opening a green gem for a sixth perfect week"
              />
              <div className="fb-caption">
                <h3 className="fb-title">A cabinet to fill</h3>
                <p className="fb-cond fb-body">
                  Every award lives in your trophy cabinet. Tap one to see when you
                  earned it.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Videos */}
        <section id="videos" className="fb-section fb-split">
          <div>
            <h2 className="fb-h2">Perfect your technique with daily videos.</h2>
            <p className="fb-cond fb-lead">
              Fresh videos every day for each of your workout types, from core to
              cardio to strength. Pick a type and press play.
            </p>
          </div>
          <div className="fb-single">
            <Phone src="videos.jpg" alt="The Videos tab, with workout videos sorted by type" />
          </div>
        </section>

        {/* Widgets */}
        <section id="widgets" className="fb-section fb-section--face fb-split fb-split--flip">
          <div className="fb-single">
            <Phone src="widgets.jpg" alt="Two FitBurst widgets on the Home Screen, showing this week's workouts" />
          </div>
          <div>
            <h2 className="fb-h2">Stay motivated with widgets.</h2>
            <p className="fb-cond fb-lead">
              Put your week on your Home Screen. Pick a widget size and a background,
              and every workout day lights up the moment you record it.
            </p>
          </div>
        </section>

        {/* About */}
        <section className="fb-section fb-about">
          <Image src="/logo-clear.png" alt="" width={512} height={512} className="fb-about-logo" />
          <h2 className="fb-h2">Made by a dad and his son.</h2>
          <p className="fb-cond fb-lead">
            We built FitBurst together to learn how apps are made, and to make working
            out a bit more fun. Questions or ideas? We&rsquo;d love to hear them.
          </p>
          <div className="fb-about-actions">
            <StoreButton className="fb-cta--hero" />
            <a className="fb-cond fb-link" href={contactHref}>
              Email us
            </a>
          </div>
        </section>
      </main>

      <footer className="fb-cond fb-foot">
        <span>© {new Date().getFullYear()} Piero Sierra</span>
        <span className="fb-foot-links">
          <a href="/privacy">Privacy</a>
          <a href={contactHref}>Contact</a>
          <a href={APP_STORE_URL} {...external}>
            App Store
          </a>
        </span>
      </footer>
    </div>
  );
}
