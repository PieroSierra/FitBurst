import type { Metadata } from "next";
import { CONTACT_EMAIL } from "../appStore";

export const metadata: Metadata = {
  title: "Privacy policy for FitBurst",
  alternates: { canonical: "/privacy" },
};

export default function Privacy() {
  return (
    <div className="fb">
      <header className="fb-header">
        <a className="fb-brand" href="/">
          <img src="/logo.png" alt="" width={64} height={64} className="fb-mark" />
          <span className="fb-wordmark">FitBurst</span>
        </a>
      </header>
      <main className="fb-doc fb-cond">
        <h1>Privacy policy for FitBurst</h1>
        <p>
          The <strong>FitBurst</strong> app does not collect, store, or share any personal
          information from users.
        </p>

        <h2>Data collection</h2>
        <ul>
          <li>
            <strong>No personal data collected:</strong> FitBurst does not collect any
            personal information, such as names, email addresses, or phone numbers.
          </li>
          <li>
            <strong>No tracking or analytics:</strong> FitBurst does not gather or track
            any data, including anonymized usage statistics or analytics.
          </li>
          <li>
            <strong>No access to device features:</strong> FitBurst does not access your
            device&rsquo;s camera, microphone, contacts, or any other sensitive data.
          </li>
        </ul>

        <h2>Third-party services</h2>
        <ul>
          <li>
            <strong>No third-party data sharing:</strong> Since FitBurst does not collect
            any personal data or display any advertising, it does not share any data with
            third-party services.
          </li>
        </ul>

        <h2>User control</h2>
        <ul>
          <li>
            <strong>No permissions required:</strong> FitBurst does not require any
            permissions from users, as it does not interact with sensitive data or device
            features.
          </li>
        </ul>

        <p>
          If you have any questions or concerns about this privacy policy, contact us at{" "}
          <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
        </p>
      </main>
    </div>
  );
}
