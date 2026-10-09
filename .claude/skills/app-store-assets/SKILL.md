---
name: app-store-assets
description: Create, review and validate App Store product page assets and metadata against Apple's official 2026 rules (iOS 27) — screenshots, app preview videos, app icon (Icon Composer / Liquid Glass), iOS 27 creative assets (product page header, search results), In-App Event media, promoted In-App Purchase images, plus app name, subtitle, keywords, description, promotional text, What's New, custom product pages and product page optimization. Use this whenever the user is preparing an App Store submission or update, making or checking screenshots or preview videos, designing an app icon, writing App Store copy or keywords (ASO), fixing a metadata rejection (Guideline 2.3.x, 4.1, 5.2), or asks which sizes/specs/limits Apple requires — even if they never say "App Store assets".
---

# App Store Assets

Help the user ship App Store assets and metadata that (1) App Store Connect accepts, (2) App Review approves, and (3) actually convert. Everything here comes from Apple's official documentation (fetched October 2026); the reference files cite the source pages.

## How to work

1. **Classify the request.** Most requests are one of: plan the whole product page · write copy/keywords · produce screenshots · produce an app preview · design/check the app icon · creative assets (header/search results) · In-App Event media · promoted IAP image · review existing assets/metadata · fix a rejection.
2. **Ground it in the real app.** Before writing copy or planning screenshots, look at the project: README, existing metadata docs, main SwiftUI views/tabs, `Info.plist`, `TARGETED_DEVICE_FAMILY` in the `.xcodeproj` (iPhone only = `1`, iPad = `2`, both = `1,2`), localizations (`*.lproj`, `Localizable.xcstrings`), StoreKit/IAP code, ads SDKs, login requirements. Assets must reflect the app's *actual* core experience — inventing features is a Guideline 2.3.1 violation, and you can't write a good story about an app you haven't looked at.
3. **Load only the reference you need** (table below). Specs change often, so quote numbers from the reference file rather than from memory.
4. **Produce the deliverable**, then **validate it with the scripts** whenever there are files or text to check.
5. **Report** with each issue tagged by severity, and say which official rule backs it.

| Task | Read |
|---|---|
| Pixel sizes, formats, durations, required device sizes, file limits | `references/specs.md` |
| What gets rejected (App Review 2.3 / 4.1 / 5.2) and Apple marketing/trademark rules | `references/review-rules.md` |
| Name, subtitle, keywords, description, promo text, What's New, IAP text, categories, localization, CPP, PPO | `references/product-page.md` |
| Screenshots, app previews, creative assets, In-App Event media — design & storytelling | `references/visual-assets.md` |
| App icon (Icon Composer, layers, appearances, sizes) | `references/app-icon.md` |
| Capturing on Simulator, status bar, exporting previews with ffmpeg | `references/production.md` |

## Severity levels

Use these consistently in every review so the user knows what is urgent:

- **BLOCKER** — App Store Connect refuses the upload, or it's an explicit App Review Guideline violation (likely rejection).
- **WARNING** — Breaks an Apple best practice or marketing guideline; hurts conversion or risks a reviewer flag.
- **TIP** — Optional improvement for conversion/ASO.

Label anything that is your own heuristic (not written by Apple) as such. Don't present a heuristic as an Apple rule.

## Non-negotiables (always in mind)

These are the rules most often broken. They're short on purpose; details are in the references.

- **Truthful**: screenshots show the app *in use* (not just splash/login/title art) — 2.3.3. Previews use only screen captures of the app itself — 2.3.4. Nothing promises features the app doesn't have — 2.3.1.
- **Paid content disclosed**: if featured items/levels/features need an IAP or subscription, say so in description, screenshots and previews — 2.3.2.
- **No prices, discounts, URLs or © in visual assets**; no prices or irrelevant terms in name/subtitle/keywords — 2.3.7 + asset best practices.
- **No other platforms**: no Android, Google Play, other marketplaces, their logos or devices — 2.3.10.
- **No Apple badges or awards you can't claim**: no "Editor's Choice", "App of the Day", "Apple Design Award", no implied Apple endorsement — 5.2.4. No unverifiable claims ("#1", "best", fake awards).
- **4+ for everything shown**: icons, screenshots, previews and creative assets must suit a 4+ rating even if the app is 17+ — 2.3.8.
- **Rights & privacy**: you must own/licence every image, font, song, map tile and brand shown; use fictional account data, never a real person's — 2.3.9.
- **No trademarks of others** in name, icon or keywords (no competitor names) — 2.3.7, 4.1(c), 5.2.1.
- **Images: no alpha channel** (screenshots and creative assets). Icon: square, unmasked, layered via Icon Composer.
- **Localize** text overlays for every language you ship; missing localized media falls back to another language.

## Quick specs (most common — full tables in `references/specs.md`)

| Asset | Size | Notes |
|---|---|---|
| iPhone screenshots — 6.9" (Dynamic Island large) | **1320×2868** (also 1290×2796, 1260×2736) | Best "master" size; smaller iPhones scale from it |
| iPhone screenshots — 6.1" (Dynamic Island medium) | **1206×2622** or 1179×2556 | ASC lists this as the required iPhone size — upload a set |
| iPhone screenshots — 6.5" (Face ID large) | 1284×2778 or 1242×2688 | Required if no 6.9" set is provided |
| iPad screenshots — 13" | **2064×2752** or 2048×2732 | Required if the app runs on iPad |
| Screenshots count / format | 1–10 per device size & language | .png/.jpg/.jpeg, RGB, no transparency |
| App preview (all modern iPhones) | **886×1920** portrait / 1920×886 landscape | 15–30 s, ≤30 fps, H.264 10–12 Mbps or ProRes 422 HQ, ≤500 MB, up to 3 per size/language |
| App preview (iPad 13"/11") | 1200×1600 / 1600×1200 | Same video rules |
| App icon | 1024×1024 square layers | Icon Composer `.icon`; system masks corners |
| Product page header (iOS 27) | 21:9 **3840×1646** (or 16:9 5244×2950 .png) | Image or 5–30 s looping video, 30/60 fps |
| Search results asset (iOS 27) | 3:2 **1920×1280 → 3840×2560** (or 16:9 5244×2950 .png) | Image or 5–30 s video, always muted |
| In-App Event card / details | 16:9 1920×1080→3840×2160 / 9:16 1080×1920→2160×3840 | Video 15–30 s, 30/60 fps, ≤500 MB |
| Promoted IAP image | 1024×1024 | JPG/PNG, flattened, no rounded corners, not a screenshot, no text |

| Text field | Limit |
|---|---|
| App name | 2–30 chars |
| Subtitle | 30 chars |
| Promotional text | 170 chars (editable anytime, no review of a new version) |
| Description | 4000 chars, plain text |
| Keywords | 100 **bytes**, comma-separated, no space after commas |
| What's New | 4000 chars |
| IAP display name / description | 30 / 45 chars (App Store Connect field limits) |
| In-App Event name / short / long | 30 / 50 / 120 chars |

## Validation scripts

Both scripts are dependency-free Python 3 (Pillow and ffprobe are used if present for extra checks). Run them from the skill directory or with absolute paths.

```bash
# Images and videos: matches each file to the App Store slot(s) it fits,
# flags wrong sizes, alpha channels, bad formats, preview length/fps/size.
python3 scripts/check_assets.py path/to/screenshots/ path/to/preview.mp4 [--ipad]

# Text metadata from a JSON file (see the docstring for the schema):
# limits, keyword bytes/duplicates/waste, forbidden or risky terms.
python3 scripts/check_metadata.py metadata.json
```

`check_metadata.py --template > metadata.json` prints a starter file. If the user's metadata lives in Markdown (e.g. `docs/APP_STORE_METADATA.md`), transcribe the fields into that JSON first rather than eyeballing character counts — counts by eye are unreliable, and keywords are measured in UTF-8 bytes, not characters.

## Deliverable formats

**Review / audit** — lead with a one-line verdict, then:

```
| Severity | Asset / field | Problem | Fix | Rule |
|---|---|---|---|---|
| BLOCKER | Keywords | 112 bytes (max 100) | drop "kebab" (already in name) … | ASC limit |
```

Then the corrected text or the exact sizes to re-export.

**Screenshot plan** — one row per screenshot, in order: `# · screen to capture · caption (≤ ~6 words, per language) · what it proves · notes (IAP disclosure, dark mode…)`. The first 3 carry the story because they appear in search results.

**Copy** — give every field ready to paste with its character count (bytes for keywords), per language.

**Preview storyboard** — beats with timestamps (0–3 s hook … loop back), poster frame choice, overlay text, audio plan, and the export command.

## Things that trip people up

- The App Store checks *exact* pixel sizes. A 1290×2796 screenshot is accepted; 1290×2795 is rejected. Simulator screenshots of the right device are already exact — don't resize them unless the target size differs.
- App previews use *accepted* resolutions (e.g. 886×1920), not the device's native resolution. Raw Simulator recordings must be re-encoded.
- Promotional text doesn't affect search ranking; keywords, name and subtitle do. Don't repeat words across name, subtitle and keywords — they're already indexed (app name and company name are searchable automatically).
- Changing the app icon needs a new binary; screenshots/previews need a new version **unless** you go through Asset Library / custom product pages / product page optimization; creative assets can be approved standalone via Asset Library and swapped on a live version without a new submission.
- Poster frames can't be edited after the preview is approved (changing it means resubmitting the preview).
- iOS 27 creative assets are optional and *separate* from screenshots: they can show brand/seasonal/lifestyle imagery, but still must relate to the app's functionality and follow the same 4+/no-prices/no-other-platforms rules.

## Language

Write in the user's language. App Store copy should be in the storefront's language (e.g. `pt-PT` copy for Portugal uses European Portuguese, not Brazilian), and keep Apple trademarks in English (App Store, iPhone, Apple Watch).
