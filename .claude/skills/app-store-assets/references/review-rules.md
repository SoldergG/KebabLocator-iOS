# What gets rejected — App Review & Apple marketing rules

Sources (fetched October 2026):
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/ (§2.3, §4.1, §5.1.4, §5.2)
- App Store asset best practices: https://developer.apple.com/app-store/asset-best-practices/
- App Store Marketing Guidelines: https://developer.apple.com/app-store/marketing/guidelines/

Use the guideline number when you report an issue so the user can look it up or quote it back to App Review.

## Contents
1. Guideline 2.3 Accurate Metadata (full summary)
2. Other guidelines that hit metadata (4.1, 5.1.4, 5.2)
3. Asset best-practice rules (creative assets, screenshots, previews)
4. Marketing guidelines: devices, status bar, trademarks, badge
5. Rejection quick-scan checklist

---

## 1. Guideline 2.3 — Accurate Metadata

> Customers should know what they're getting when they download or buy your app, so make sure all your app metadata, including privacy information, your app description, screenshots, and previews accurately reflect the app's core experience and remember to keep them up-to-date with new versions.

| § | Rule (paraphrased closely) | What to check |
|---|---|---|
| 2.3.1(a) | No hidden/dormant/undocumented features; describe new features in **Notes for Review** with specificity. Misleading marketing (content/services not offered, false price) — even outside the App Store — can mean removal and account termination. | Every claim in copy/screens exists in the build being reviewed. |
| 2.3.1(b) | Egregious or repeated dishonesty → removal from the Developer Program. | — |
| 2.3.2 | If featured items, levels, subscriptions etc. need extra purchases, the **description, screenshots and previews must say so clearly**. Promoted IAP name/screenshot/description must suit a public audience. | Subscription/IAP/paywalled features shown? → disclosure text (e.g. "Requires Premium"). |
| 2.3.3 | Screenshots show the **app in use** — not only title art, login page or splash screen. Text/image overlays allowed (e.g. touch point, Apple Pencil). | No login-screen or splash-only screenshots. |
| 2.3.4 | Previews may only use **video screen captures of the app itself** (Messages for stickers/iMessage). Narration and video/text overlays are allowed. | No live-action, no device footage, no renders of features. |
| 2.3.5 | Choose the most appropriate category; Apple may change it. | Category matches core function. |
| 2.3.6 | Answer age-rating questions honestly. | — |
| 2.3.7 | Unique name; accurate keywords; **no trademarked terms, popular app names, pricing info or irrelevant phrases** to game search. Name ≤ 30 chars. Name, subtitle, screenshots and previews must not include **prices, terms, or descriptions not specific to that metadata type**. Subtitles: no inappropriate content, **no references to other apps, no unverifiable claims**. Apple may modify keywords. | "Free", "€0.99", "50% off", "best", "#1", competitor names in name/subtitle/keywords. |
| 2.3.8 | Icons, screenshots and previews (incl. IAP icons) must be **4+**, even if the app is rated higher. "For Kids"/"For Children" reserved for the Kids category. Name and icons (small, large, Watch, alternate) should be similar to avoid confusion. | Violence, gore, weapons aimed at characters, suggestive imagery. |
| 2.3.9 | You must secure rights to **all materials** in icons, screenshots, previews. Use **fictional account information**, not a real person's data. | Real names/emails/phones/addresses, real users' photos, licensed music/fonts/maps. |
| 2.3.10 | Focus on Apple platforms; **no names, icons or imagery of other mobile platforms or alternative app marketplaces** (unless approved interactive functionality). No irrelevant information. | "Also on Android", Google Play badge, Android phone frames. |
| 2.3.11 | Pre-order apps must be complete and not materially different from what's advertised. | — |
| 2.3.12 | **What's New** must clearly describe new features/changes; generic text is fine only for bug fixes/security/performance. | "Bug fixes" on a release that added features → reject. |
| 2.3.13 | In-App Events: must fit an event type, metadata accurate and **about the event**, happen at the dates set, deep link goes to the right place. | — |

## 2. Other guidelines that hit metadata

| § | Rule |
|---|---|
| 4.1(a) | Don't copy another app or make minor changes to its name/UI. |
| 4.1(b) | Impersonating other apps/services violates the Code of Conduct. |
| 4.1(c) | Don't use **another developer's icon, brand or product name** in your icon or name without approval. |
| 5.1.4(b) | Apps not in the Kids category can't use terms in name, subtitle, icon, screenshots or description implying children are the main audience. |
| 5.2.1 | No protected third-party material (trademarks, copyrighted works) without permission; no misleading/copycat names or metadata. |
| 5.2.4(a) | Don't suggest Apple is a source/supplier of the app or endorses it. |
| 5.2.4(b) | Editor's Choice badge is applied by Apple automatically — never add it yourself. |
| 5.2.5 | Don't look confusingly similar to an Apple product, interface (e.g. Finder), app (App Store, Messages…) or advertising theme. No Apple emoji in apps/extensions. Activity rings must not mimic the Activity control. Apple Weather data needs WeatherKit attribution. |

## 3. Asset best-practice rules (asset-best-practices page)

These apply to **all** visual assets — screenshots, previews and the iOS 27 creative assets:

- **Don't include specific pricing, discounts, website URLs, copyright symbols** (keeps assets global and evergreen).
- **Avoid unverifiable claims** — awards or recognition the app hasn't actually received.
- **No logos or references to other platforms or marketplaces.**
- **No Apple-designated recognitions** — Editor's Choice, App of the Day, Game of the Day, Apple Design Award winner (Apple already shows these).
- Content outside the app is allowed in *creative assets* but **must still relate to the app's general functionality**.
- **4+ for all assets**; no explicit/harmful imagery, profanity, illegal drugs, self-harm, hate speech, stereotypes, sexually suggestive content, inflammatory religious commentary, or misquoted religious texts.
- Games with violence may use action imagery but **no gore, graphic imagery, or weapons pointed directly at a person or at the viewer**.
- Build for a global audience; localize images and videos per region.
- Screenshots: stay on the core user experience — **don't use a whole screenshot for accolades or call-to-action statements**.

From "Show more with app previews":
- Don't film people interacting with a device (over-the-shoulder, fingers tapping). Stay inside the app.
- Show more gameplay than cutscenes.
- Transitions must not imply functionality the app doesn't have; prefer dissolves/fades.
- Avoid seasonal/timely references that age the video ("new for spring", dates) and specific prices.
- **Disclose** if shown features require IAP, a subscription or login (in footage or end frame).

From In-App Events guidance:
- No all-caps, no "!!", no "the best"/"#1", no specific prices, no calls to action as event names, no text/logos in event media where possible, no borders/gradients.

## 4. Marketing guidelines (devices, screens, trademarks)

Applies to screenshots and creative assets that show devices, and to any external marketing.

**Device imagery**
- Only use **Apple-provided product bezels** (Apple Design Resources), latest-generation devices the app supports.
- Use product images as-is: no added reflections/shadows/graphics entering or leaving the screen; don't crop, tilt, obstruct, animate, flip or spin them. Promotional copy goes **beside** devices, not on top.
- Keep correct relative scale between products. Never show an Apple product next to a competitor's device.
- No 3D renders or illustrations of Apple products (except instructional), no generic devices with Apple-specific details (Home button, sensor housing, switches).
- Don't feature or obscure the Apple logo; no cases/covers.

**Screen content**
- Show the app as it actually looks, on the **latest OS**. No blank screens.
- Fictional account info only. You're responsible for rights to everything on screen (incl. store names/locations).
- **Status bar** (iPhone/iPad): full network designator, **full Wi-Fi**, **full battery**. Show 5G only if the app is optimized for it. Full-screen apps may cover the status bar.
- Notifications: a single notification on the Lock Screen, from your app only. Don't show the Home Screen — except your widget when no third-party content is visible.

**Wording & trademarks**
- "*App name* for iPhone" / "works with iPhone" — never "*iPhone App name*". Don't mention iOS/macOS/watchOS/tvOS in marketing. Don't call Apple devices "smartphones/tablets".
- Write names exactly: iPhone, iPad (lowercase i), Apple Watch, Apple TV, Apple Vision Pro (no "the", never "headset"; say *spatial computing* app, not AR/VR/XR/MR), App Store ("on the App Store", never "Apple App Store" or "at the App Store"), Apple Pay, Siri, iMessage, Apple In-App Purchase.
- Keep Apple trademarks in English even in localized copy.
- Never start a URL with an Apple trademark (`company.com/app/iphone` ok, `iphoneapp.com` not ok).

**"Download on the App Store" badge** (external marketing — never inside App Store screenshots)
- Black badge preferred; white only when black is too heavy and it's the only badge. With other stores' badges, App Store badge goes first.
- Only Apple's artwork; only "Download on the"/"Pre-order on the" is localized; "App Store" stays English.
- One badge per layout, subordinate position, not modified/angled/animated, no ™.
- Clear space ≥ ¼ badge height (⅒ in tiny mobile banners). Min size 40 px on screen, 10 mm in print.

## 5. Rejection quick-scan checklist

Run through this on any review. Each line maps to a rule above.

- [ ] Every screenshot shows the app in use; none is just splash/login/title art (2.3.3)
- [ ] Preview is 100% screen capture of the app; no hands/devices/live action (2.3.4)
- [ ] Every claimed feature exists in this build (2.3.1)
- [ ] IAP/subscription/login-gated features are disclosed in copy, screenshots and previews (2.3.2)
- [ ] No prices, "% off", "free trial €X", currency symbols, URLs or © in any visual asset (2.3.7, best practices)
- [ ] Name/subtitle/keywords: no prices, no "free" as a pricing term, no competitor or trademark names, no "best/#1" (2.3.7)
- [ ] No Android/Google Play/other store names, logos or devices (2.3.10)
- [ ] No Apple awards/badges, no implied Apple endorsement, no Apple emoji (5.2.4, 5.2.5)
- [ ] All imagery 4+; no gore/weapons aimed at people (2.3.8)
- [ ] Fictional data only — no real names, emails, phone numbers, faces you don't have rights to (2.3.9)
- [ ] Rights cleared for photos, fonts, music, map tiles, third-party logos/brands (2.3.9, 5.2.1)
- [ ] "For Kids"/"For Children" only if in Kids category (2.3.8, 5.1.4)
- [ ] What's New lists real changes (2.3.12)
- [ ] Icon doesn't reuse another brand's icon/name (4.1(c))
- [ ] Device frames are Apple's official bezels, untouched; status bar full Wi-Fi/battery (marketing guidelines)
