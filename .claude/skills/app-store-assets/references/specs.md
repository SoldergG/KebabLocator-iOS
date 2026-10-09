# App Store technical specifications

Source pages (fetched October 2026 — re-check them if something looks off, Apple updates these when new devices ship):
- Screenshots: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- App previews: https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
- Creative assets: https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications/
- In-App Event media: https://developer.apple.com/help/app-store-connect/reference/in-app-events/in-app-event-media-and-audio-specifications
- App icons (HIG): https://developer.apple.com/design/human-interface-guidelines/app-icons
- IAP information: https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information

## Contents
1. Screenshots
2. App previews
3. Creative assets (product page header, search results) — iOS 27
4. In-App Event media
5. App icon
6. Promoted In-App Purchase image
7. Text field limits
8. Recommended minimal upload set

---

## 1. Screenshots

**General rules**
- At least 1, up to **10 per device size** (per localization).
- Formats: `.jpeg`, `.jpg`, `.png`. **No alpha channels or transparency.**
- Must follow the App Review Guidelines (2.3.3: show the app in use).
- If the UI is the same across sizes and localizations, provide only the highest required resolution; App Store Connect scales down.
- Sizes are checked exactly — any other pixel size is rejected on upload.

**Required (official wording)**
- iPhone: *at least one screenshot for iPhone with Dynamic Island (medium display)*.
- iPhone with Face ID (large display): *required if the app runs on iPhone and screenshots for iPhone with Dynamic Island (large display) aren't provided*.
- iPad (if the app supports iPadOS): *at least one screenshot for iPad 13-inch display*.
- Mac / Apple TV / Apple Vision Pro / Apple Watch: required only for apps on those platforms.
- iPhone Duo: starting **April 2027**, required for any app built with the **iOS 27.1 SDK or later**.

### iPhone

| Display class | Devices | Portrait | Landscape | Fallback if missing |
|---|---|---|---|---|
| iPhone Duo — outer | iPhone Duo | 1398×2034 | 2034×1398 | — (required from Apr 2027 w/ iOS 27.1 SDK) |
| iPhone Duo — inner | iPhone Duo | 2007×2853 | 2853×2007 | — |
| Dynamic Island, large (6.9") | iPhone Air, 18 Pro Max, 17 Pro Max, 16 Pro Max, 16 Plus, 15 Pro Max, 15 Plus, 14 Pro Max | 1260×2736 · 1290×2796 · **1320×2868** | 2736×1260 · 2796×1290 · 2868×1320 | scaled from Face ID large |
| Face ID, large (6.5") | 14 Plus, 13 Pro Max, 12 Pro Max, 11 Pro Max, 11, XS Max, XR | 1284×2778 · 1242×2688 | 2778×1284 · 2688×1242 | scaled from Dynamic Island large |
| Dynamic Island, medium (6.1"/6.3") | 18 Pro, 17 Pro, 17, 16 Pro, 16, 15 Pro, 15, 14 Pro | 1179×2556 · **1206×2622** | 2556×1179 · 2622×1206 | scaled from Face ID large |
| Face ID, medium (5.8"/6.1") | 17e, 16e, 14, 13 Pro, 13, 13 mini, 12 Pro, 12, 12 mini, 11 Pro, XS, X | 1170×2532 · 1125×2436 · 1080×2340 | 2532×1170 · 2436×1125 · 2340×1080 | scaled from Dynamic Island medium |
| Home Button, large (5.5") | 8 Plus, 7 Plus, 6S Plus, 6 Plus | 1242×2208 | 2208×1242 | scaled from Face ID medium |
| Home Button, medium (4.7") | SE (3rd/2nd), 8, 7, 6S, 6 | 750×1334 | 1334×750 | scaled from Home Button large |
| Home Button, 4" | SE (1st), 5S, 5C, 5 | 640×1096 (no status bar) · 640×1136 | 1136×600 · 1136×640 | scaled from Home Button medium |
| Home Button, 3.5" | 4S, 4 | 640×920 (no status bar) · 640×960 | 960×600 · 960×640 | scaled from 4" |

### iPad

| Display | Devices | Portrait | Landscape | Requirement / fallback |
|---|---|---|---|---|
| 13" | iPad Pro (M5, M4, 6th/5th/4th/3rd/1st gen), iPad Air (M4, M3, M2) | **2064×2752** · 2048×2732 | 2752×2064 · 2732×2048 | **Required if app runs on iPad** |
| 12.9" | iPad Pro (2nd gen) | 2048×2732 | 2732×2048 | scaled from 13" |
| 11" | iPad Pro (M5, M4, 4th–1st gen), iPad Air (M4, M3, M2, 5th, 4th), iPad (A16, 10th), iPad mini (A17 Pro, 6th) | 1488×2266 · 1668×2420 · 1668×2388 · 1640×2360 | 2266×1488 · 2420×1668 · 2388×1668 · 2360×1640 | scaled from 13" |
| 10.5" | iPad Pro, iPad Air (3rd), iPad (9th/8th/7th) | 1668×2224 | 2224×1668 | scaled from 12.9" |
| 9.7" | older iPad / iPad Air / iPad mini 2–5 | 1536×2008 (no status bar) · 1536×2048 · 768×1004 · 768×1024 | 2048×1496 · 2048×1536 · 1024×748 · 1024×768 | scaled from 10.5" |

### Other platforms

| Platform | Accepted sizes |
|---|---|
| Mac (16:10) | 1280×800, 1440×900, 2560×1600, 2880×1800 |
| Apple TV | 1920×1080, 3840×2160 |
| Apple Vision Pro | 3840×2160 |
| Apple Watch Ultra 4 / Ultra 3 | 422×514 |
| Apple Watch Ultra 2 / Ultra | 410×502 |
| Apple Watch Series 12 / 11 / 10 | 416×496 |
| Apple Watch Series 9 / 8 / 7 | 396×484 |
| Apple Watch Series 6 / 5 / 4 / SE 3 / SE 2 / SE | 368×448 |
| Apple Watch Series 3 / 2 / 1 | 312×390 |

Apple Watch: use the same screenshot size across all localizations.

---

## 2. App previews

**General**
- Optional. Up to **3 per device size and language** (iOS, macOS, tvOS, visionOS). Not available for iMessage apps.
- Always shown **before** screenshots on iPhone, iPad, Mac and Apple TV. If its aspect ratio differs from the screenshots, it appears in the "A Closer Look" section instead.
- Autoplays **muted** on the product page and in search results; poster frame shows when autoplay is off. Default poster frame = **5 s**. Poster frame **can't be edited after approval**.
- Orientation: iOS portrait or landscape; macOS/tvOS/visionOS landscape only.
- Processing after upload: up to 24 h.
- Missing localized preview → next best available language is used.

**File requirements**

| | H.264 | ProRes 422 (HQ only) |
|---|---|---|
| Containers | .mov, .m4v, .mp4 | .mov |
| Target bit rate | 10–12 Mbps | VBR ~220 Mbps |
| Video | Progressive, up to High Profile Level 4.0 | Progressive, no external references |
| Max frame rate | 30 fps | 30 fps |
| Audio | Stereo, 256 kbps AAC, 44.1 or 48 kHz | Stereo, PCM (16/24/32-bit) or 256 kbps AAC, 44.1 or 48 kHz |
| Stereo layout | 1 track × 2 channels (L, R) **or** 2 tracks × 1 channel (L, R); all tracks enabled | same |
| Length | **15–30 s** | 15–30 s |
| Max file size | **500 MB** | 500 MB |

**Accepted resolutions** (use these, *not* the device's native resolution)

| Display | Portrait | Landscape | Fallback |
|---|---|---|---|
| iPhone Duo | 886×1920 | 1920×886 | — |
| iPhone 6.9" Dynamic Island large | **886×1920** | 1920×886 | Face ID large |
| iPhone 6.5" Face ID large | 886×1920 | 1920×886 | Dynamic Island large |
| iPhone 6.1" Dynamic Island medium | 886×1920 | 1920×886 | Face ID large |
| iPhone 5.8" Face ID medium | 886×1920 | 1920×886 | Dynamic Island medium |
| iPhone 5.5" Home Button large | 1080×1920 | 1920×1080 | Face ID medium |
| iPhone 4.7" Home Button medium | 750×1334 | 1334×750 | Home Button large |
| iPhone 4" | 1080×1920 | 1920×1080 | Home Button medium |
| iPhone 3.5" | not supported | | |
| iPad 13" | **1200×1600** | 1600×1200 | — |
| iPad 12.9" (2nd gen) | 1200×1600 · 900×1200 | 1600×1200 · 1200×900 | 13" |
| iPad 11" | 1200×1600 | 1600×1200 | 13" |
| iPad 10.5" | 1200×1600 | 1600×1200 | 12.9" |
| iPad 9.7" | 900×1200 | 1200×900 | 10.5" |
| Mac | — | 1920×1080 | landscape only |
| Apple TV | — | 1920×1080 | landscape only |
| Apple Vision Pro | — | 3840×2160 | landscape only |

---

## 3. Creative assets — iOS 27 / iPadOS 27

Rich images/videos for brand, seasonal offers, new content. Optional and **separate** from screenshots, previews, IAP images and editorial artwork. Shown on iOS 27 / iPadOS 27 and later. Can also be used in custom product pages, product page optimization tests and Apple Ads (Today tab, Search).

**Images** (no alpha / transparency)

| Placement | Aspect | Resolution | Formats |
|---|---|---|---|
| Product page header | 21:9 | 3840×1646 | .jpeg, .jpg, .png |
| Product page header | 16:9 | 5244×2950 | .png |
| Search results | 3:2 | min 1920×1280 – max 3840×2560 | .jpeg, .jpg, .png |
| Search results | 16:9 | 5244×2950 | .png |

The 16:9 5244×2950 PNG row is listed under *both* placements without a label. App Store Connect separately describes a **universal creative asset** that can serve both header and search results (only universal assets offer "Use header asset in search results"), and Apple ships "Universal" templates for it — so the 16:9 PNG is almost certainly that universal format (inference; the spec page doesn't say it outright). Download the Universal template to get the exact safe areas, and keep the focal point centered so each placement's crop works.

**Videos**

| Placement | Aspect | Resolution | fps | Length | Formats |
|---|---|---|---|---|---|
| Product page header | 21:9 | 3840×1646 | 30 or 60 | 5–30 s | .mov, .m4v, .mp4 |
| Search results | 3:2 | 1920×1280 – 3840×2560 | 30 or 60 | 5–30 s | .mov, .m4v, .mp4 |

- Videos **loop continuously** in both placements.
- Search results: muted, **can't be unmuted**. Product page: muted by default, people can unmute.

**Templates** (official): https://developer.apple.com/app-store/asset-best-practices/ — Figma (Universal), Photoshop (Header, Search results, Universal), Pixelmator (Header, Search results, Universal), Sketch (Universal).

If no search results creative asset is set, In-App Events, app previews and screenshots appear in search instead.

---

## 4. In-App Event media

| Media | Formats | Aspect | Min | Max | Max size |
|---|---|---|---|---|---|
| Event card image | .jpg, .jpeg, .png | 16:9 (landscape) | 1920×1080 | 3840×2160 | 500 MB |
| Event card video | .mov, .m4v, .mp4 | 16:9 | 1920×1080 @30/60 fps | 3840×2160 @30/60 fps | 500 MB |
| Event details image | .jpg, .jpeg, .png | 9:16 (portrait) | 1080×1920 | 2160×3840 | 500 MB |
| Event details video | .mov, .m4v, .mp4 | 9:16 | 1080×1920 @30/60 fps | 2160×3840 @30/60 fps | 500 MB |

- Video length **15–30 s**; loops — make it seamless.
- Audio: stereo; card video 256 kbps AAC; details video PCM (16/24/32-bit) or 256 kbps AAC; 44.1 or 48 kHz; tracks without audio are supported.
- The App Store applies crops and gradients automatically → don't add borders or gradients.

---

## 5. App icon

| Platform | Layout | After masking | Size | Style | Appearances |
|---|---|---|---|---|---|
| iOS, iPadOS, macOS | Square | Rounded rectangle | **1024×1024** | Layered (Liquid Glass) | Default, dark, clear light, clear dark, tinted light, tinted dark |
| tvOS | Rectangle (landscape) | Rounded rectangle | 800×480 | Layered, parallax (2–5 layers) | — |
| visionOS | Square | Circle | 1024×1024 | Layered 3D (background + 1–2 layers) | — |
| watchOS | Square | Circle | 1088×1088 | Layered | — |

- Color spaces: sRGB, Gray Gamma 2.2, Display P3 (not visionOS).
- Provide **unmasked square layers** — pre-rounded corners break specular highlights and look jagged.
- Built with **Icon Composer** (ships with Xcode) for iOS/iPadOS/macOS/watchOS; tvOS/visionOS use image stacks in the asset catalog.
- Changing the icon after release requires a **new app version**.

Design guidance: `references/app-icon.md`.

---

## 6. Promoted In-App Purchase image

- **1024×1024**, JPG or PNG, 72 dpi, RGB, **flattened, no rounded corners**.
- Unique per IAP. Not a screenshot. Must not look like your app icon. **No text overlay.**
- Apple adds a frame; outside the product page your app icon sits in the **lower-left corner** — keep that area clear.
- Must stay readable at small sizes. Required to promote an IAP or to set up win-back offers; also shown when offer codes are redeemed.
- Up to **20** promoted IAPs on the product page. Consumables don't appear in search results.

---

## 7. Text field limits (App Store Connect)

| Field | Limit | Notes |
|---|---|---|
| App name | 2–30 characters | Localizable |
| Subtitle | 30 characters | Localizable |
| Promotional text | 170 characters | Editable anytime; above description; **doesn't affect search** |
| Description | 4000 characters | Plain text, no HTML; used for web search engines |
| Keywords | **100 bytes** | Comma-separated; each keyword > 2 characters; no other apps/companies |
| What's New | 4000 characters | Not available for v1.0; required for later versions |
| Copyright | "YEAR Owner" | The © symbol is added automatically — don't type it |
| IAP display name | 2–30 characters | Include duration for subscriptions |
| IAP description | 45 characters | Apple's "Creating your product page" article quotes 35/55; the App Store Connect field reference says 30/45 — **write to 30/45** so it fits both |
| In-App Event name | 30 characters | Title case |
| In-App Event short description | 50 characters | Sentence case (card) |
| In-App Event long description | 120 characters | Sentence case (details page) |
| PPO test reference name | 64 characters | Internal |
| App Review notes | 4000 bytes | Internal |

---

## 8. Recommended minimal upload set

Apple's fallback chains mean you don't need every size. A set that satisfies every requirement listed above with the least work:

**iPhone-only app**
1. 6.9" set — **1320×2868** (iPhone 17/16 Pro Max Simulator), up to 10.
2. 6.1" set — **1206×2622** (iPhone 17 / 17 Pro Simulator). Upload it even though a fallback exists, because App Store Connect names this size as *the* required iPhone size.
3. Optional preview — **886×1920**, 15–30 s, covers all modern iPhones.

**Universal (iPhone + iPad)** — the above plus:
4. iPad 13" set — **2064×2752** (iPad Pro 13-inch (M5/M4) Simulator).
5. Optional iPad preview — **1200×1600**.

**Adopting iOS 27 creative assets** — one universal 16:9 **5244×2950 PNG**, or a dedicated 21:9 header (3840×1646) + 3:2 search asset (e.g. 2880×1920).

**Coming soon** — iPhone Duo screenshots (1398×2034 outer + 2007×2853 inner) once you build with the iOS 27.1 SDK (from April 2027).
