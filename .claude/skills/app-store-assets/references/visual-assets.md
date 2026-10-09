# Visual assets — screenshots, app previews, creative assets, event media

Sources (fetched October 2026):
- Asset best practices (iOS 27): https://developer.apple.com/app-store/asset-best-practices/
- Creating your product page: https://developer.apple.com/app-store/product-page/
- Show more with app previews: https://developer.apple.com/app-store/app-previews/
- Manage your App Store assets: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets
- In-App Events: https://developer.apple.com/app-store/in-app-events/
- WWDC26 "Enhance your presence on the App Store": https://developer.apple.com/videos/play/wwdc2026/205/

Specs are in `specs.md`; rules that cause rejection are in `review-rules.md`. This file is about making assets that work.

## Contents
1. The asset family — one story, one style
2. Screenshots
3. App previews
4. Creative assets: product page header & search results (iOS 27)
5. In-App Event media
6. Promoted IAP image
7. Asset Library & submission workflow

---

## 1. The asset family

The icon, header, search asset, screenshots and previews are seen together. Apple asks that they **tell a cohesive story and look good together**: same color palette, iconography, fonts, message and tone. Decide these once (a mini style sheet) before producing anything:

- 1 background treatment (solid brand color, gradient, or the app's own UI color)
- 1 headline font + weight, 1 size scale, max ~6 words per caption
- 1 device treatment (full-bleed UI, or Apple's official bezel — not both mixed)
- Light vs dark: if the app supports Dark Mode, include at least one dark screenshot

Image principles from Apple:
- **Compelling visuals** — current-looking photography/illustration; use the latest UI; reflect the app's aesthetic; strong composition with **one clear focal point** per asset.
- **Intentional text** — a short phrase that *enhances* the visual rather than describes it. Localize it.
- **Legible everywhere** — assets render at many sizes; keep key elements and text inside a **centered safe area** to survive cropping across devices/orientations. Check in App Store Connect's **Preview** tool (iPhone, iPad, iPhone Duo, orientations, languages, Dark Mode).

## 2. Screenshots

Purpose: show what people can expect — the app **in use**, detailed and honest.

**Sequence (up to 10):**
1. Lead with the **strongest feature or benefit** — the first 1–3 show in search results (portrait apps show 3; landscape show 1).
2. Order the rest like a real session of using the app — a story, not a feature dump.
3. One benefit per screenshot. Don't spend a whole screenshot on accolades or "Download now" (Apple says avoid).
4. Include IAP disclosure where premium features appear (2.3.2) — e.g. small "Premium" tag in the caption.

**Caption formula (heuristic):** benefit verb + object, ≤ 6 words, sentence case, no trailing "!".
- Good: "Find kebabs open near you" · "Save the spots you love"
- Weak: "Map screen" (describes, doesn't enhance) · "THE BEST KEBAB APP!!" (claim + caps)

**Layout options:**
- *Full-bleed UI* — the raw screenshot is the asset. Most honest, zero design work, works well for content-rich apps.
- *Caption + UI* — caption on top (~15–20% height), UI scaled below. Most common. Keep UI readable (don't shrink below ~75% width).
- *Device frame* — only Apple's official bezels, untouched, latest device; copy beside, not over the device.
- *Panoramic* — a background that continues across adjacent screenshots; each must still work alone in search.

**Content hygiene:** status bar 9:41, full Wi-Fi/cellular/battery (`production.md`); fictional data that looks real ("Ana's Döner", not "Test Shop 1"); no debug UI, no placeholder text, no empty states unless that's the point; realistic locations you have rights to show.

## 3. App previews

Purpose: an interactive look at the real app in action. Up to 3 per size and language, 15–30 s each.

**Story structure (Apple: beginning, middle, end):**
- **0–3 s hook** — the most compelling moment first; autoplay is muted and people scroll fast.
- **Middle** — 2–4 features in order of popularity, each held long enough to grasp (avoid quick cuts and fast motion — accessibility).
- **End** — a clean frame that loops back to the start seamlessly (it autoplays and repeats).
- Multiple previews: preview 1 = overview, 2–3 = deeper features. Each must show something new.

**Rules of thumb:**
- Only screen capture of the app (2.3.4). No hands, no devices, no live action.
- Capture at native UI resolution; don't zoom into the view. Touch hotspots are OK to explain gestures.
- Transitions: dissolves and fades; never imply functionality the app lacks.
- **Works muted**: add short, legible text overlays that stay on screen long enough to read. No dates/seasons, no prices.
- **Audio** as brand texture: one music bed across the whole preview, UI sound effects OK, no sudden loud moments, loop cleanly. Voiceover only with pro-quality audio.
- Disclose IAP/subscription/login in footage or end frame.
- **Poster frame** (default 5 s): pick a frame that represents the app on its own — it's what people see when autoplay is off. Can't be changed after approval without resubmitting the preview.

**AR apps:** uncluttered, well-lit room with nothing personal or third-party; texture for tracking; in the first seconds show the object being placed so people see what's virtual. Say "AR app/AR game" only for genuine AR.

## 4. Creative assets — product page header & search results (iOS 27)

Creative assets may show things **beyond the app in use** — brand, seasonal offerings, new content, lifestyle — but must still relate to the app's general functionality and follow all 4+/no-price/no-other-platform rules.

**Product page header** — the first thing on the product page; sets the tone.
- One single, clear idea; dense or cluttered assets dilute impact.
- Design for a **first-time visitor** — what's most compelling to someone who's never heard of the app?
- Video: muted by default (user can unmute), loops. Make it silent-first.
- Ideas Apple gives: outdoor apps → aspirational imagery; travel → destinations; games → gameplay or characters.

**Search results asset** — replaces the screenshots/previews in search.
- **State the obvious**: people are looking for something specific; the app's purpose must be clear at a glance.
- **Show the firsthand experience**: interface, content or gameplay so people can decide quickly.
- Video is always muted here.
- Without one, In-App Events, previews and screenshots appear instead.

**Universal asset** — one asset for both header and search results strengthens recognition; start from Apple's Universal template so the critical area survives both crops.

**Video rules** (Apple's guidance for these placements):
- Strong **poster frame** that represents the app on its own.
- **Start strong** with the value proposition; pace cuts so people can follow; avoid fast motion.
- **Loop seamlessly** — no visible jump.
- **Audio** is muted by default: silent-first; if adding sound, a short music loop over heavy effects, no sudden loud moments, loops cleanly.

**Using them beyond the default page:** custom product pages can carry a tailored header per keyword set or campaign (and deep-link to the matching in-app content); PPO can A/B test headers; Apple Ads can reuse the same images/videos on the Today tab and in search.

## 5. In-App Event media

- Two formats: **card 16:9 landscape** and **details 9:16 portrait** — both must convey the event's essence; keep colors/illustration style continuous between them.
- Design to complement the **badge**, not duplicate it (don't write "Challenge" in the art if the badge says Challenge).
- Avoid text and logos in the media where possible (especially event or app name — already shown).
- No borders or gradients (Apple applies crops and gradients itself). Preview in App Store Connect to make sure key content isn't obscured.
- Video loops — seamless.

## 6. Promoted IAP image

Represents the item itself (a pack, a feature, a tier) — not a screenshot, not a copy of the app icon, no text. Must read at small sizes; keep the **lower-left corner clear** (the app icon is overlaid there outside the product page). Unique image per IAP.

## 7. Asset Library & submission workflow (App Store Connect, 2026)

- **Asset Library** (sidebar) holds screenshots, previews, event media and creative assets for all platforms/sizes. Upload via **+** → "Upload Creative Assets" or "Previews and Screenshots". Filter by Type/Status/Format. "Works With" shows which placements an asset fits.
- Assets can be **submitted standalone** (without a new version) once the app has an approved version; they're reviewed against the latest version of the platform you pick. For a brand-new app, include them in the first version submission.
- Assets attached to a version, CPP, PPO test or In-App Event are reviewed **with** that item and can't be submitted separately while it's in review.
- Creative assets: version page → Product Page Information → **Header and Search Results** tab → Header / Search Results → drag in or **Browse Assets**. Tick "Use header asset in search results" for universal assets.
- **Live version, new creative asset**: choose an already-approved asset → **Publish** — no new version needed.
- Screenshots/previews: version page → App Previews and Screenshots tab, or **Media Manager** ("View All Sizes") for per-size/per-language management and poster frames. Uploadable when the version is Prepare for Submission / Rejected / Metadata Rejected / Developer Rejected / Invalid Binary.
- Removing a screenshot also removes it from sizes that were using the scaled version.
- Only assets in **Prepared for Submission** can be deleted; others can be **archived** (archived assets can't be placed in new placements).
- Roles: Account Holder, Admin, App Manager or Marketing can manage assets; submitting needs Account Holder, Admin or App Manager.
- Automation: App Store Connect API (App Preview Sets, Screenshot Sets, Asset Library uploads/submissions); Apple Ads Platform API for ads.
