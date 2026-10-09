# Product page metadata — copy, keywords, ASO, CPP, PPO

Sources (fetched October 2026):
- Creating your product page: https://developer.apple.com/app-store/product-page/
- App information reference: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Platform version information: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Promoting IAPs: https://developer.apple.com/app-store/promoting-in-app-purchases/
- In-App Events: https://developer.apple.com/app-store/in-app-events/
- Custom product pages: https://developer.apple.com/app-store/custom-product-pages/
- Product page optimization: https://developer.apple.com/app-store/product-page-optimization/

## Contents
1. What's indexed for search (and what isn't)
2. Field-by-field guidance
3. Keywords: how to fill 100 bytes well
4. In-App Purchases on the product page
5. In-App Events
6. Localization
7. Custom product pages (CPP)
8. Product page optimization (PPO)
9. Ratings & reviews

---

## 1. What's indexed for search

| Indexed (per Apple docs) | Not indexed / not for keywords |
|---|---|
| App name, subtitle, keywords, developer/company name ("Your app is searchable by app name and company name"). Promoted IAPs can also surface in search. | Promotional text ("doesn't affect your app's search ranking"); description ("don't add unnecessary keywords" — it *is* used for web search engines) |

Consequences:
- Never repeat a word across name, subtitle and keywords — it's already indexed once; repetition wastes characters.
- Don't put the app name or company name in keywords (already searchable).
- Promotional text is for news, not keywords.

## 2. Field-by-field

### App name — 2–30 characters
Simple, memorable, easy to spell, hints at what the app does, distinctive. Avoid generic terms or names close to existing apps (2.3.7, 4.1). Can be localized. Brand first; a short descriptor after a dash is common ("Kebab Locator – Food Map") but every word must be true and non-promotional.

### Subtitle — 30 characters
A concise phrase that explains the value — **not** "world's best app". Highlight a feature or typical use that resonates. Shown under the name everywhere on the App Store. Can be changed with each new version (test it). No prices, no other apps, no unverifiable claims (2.3.7).

### Promotional text — 170 characters
Sits above the description. **Editable anytime without a new version.** Use for current news: a new feature, a seasonal event, a limited-time sale (wording, not a specific price is safest). Doesn't affect search.

### Description — 4000 characters, plain text
- Ideal shape: one concise, informative paragraph, then a short list of main features.
- **The first sentence matters most** — it's what people read before "more".
- Say what makes the app unique and why people will love it, in the brand's tone, with the audience's vocabulary.
- If mentioning an accolade, put it at the end (or in promo text). Must be real.
- No keyword stuffing. **No specific prices** (they vary per region and are already shown).
- Disclose IAP/subscription requirements for featured items (2.3.2).
- Plain text; line breaks OK; no HTML. Emoji bullets are allowed but use them sparingly and consistently (heuristic, not an Apple rule).

### What's New — 4000 characters
Not available on v1.0; required afterwards. List new features/content in order of importance; credit user feedback ("You asked, we built…"); a call to action is fine. Significant changes must be described — "bug fixes and improvements" only for genuine maintenance releases (2.3.12).

### Category — primary + secondary
The primary category drives discoverability and which tab the app appears in. An irrelevant category can cause rejection (2.3.5). Games/Stickers can add up to two subcategories. Note: in iOS 27, Entertainment/Games categories also place the app into **Time Allowance** groups for parental controls.

### Screenshots & previews
See `visual-assets.md`. The first 1–3 screenshots appear in search results when there's no preview (and no iOS 27 search creative asset), so they must carry the essence of the app. If the app supports Dark Mode, consider at least one dark screenshot.

### Copyright
"2026 Your Name" — App Store Connect adds the © automatically; typing © yourself duplicates it.

## 3. Keywords — 100 bytes

Rules (App Store Connect + product page article):
- Comma-separated, **no spaces after commas**; spaces inside a phrase are fine (`real estate`).
- Each keyword longer than 2 characters.
- Limit is **100 bytes** of UTF-8 — accented letters (ã, ç, é, ü) cost 2 bytes each. Non-Latin scripts cost more.
- Don't include: plurals of words already present, the word "app", category names, duplicates, special characters like # or @ (unless part of the brand), the app's own name or company name.
- Never: trademarks, celebrity names or protected terms you don't own; **competitor app names**; irrelevant or offensive terms. Misuse is a common rejection reason (2.3.7).

Strategy:
- Search matches words from name, subtitle and keywords in combination, so prefer **single words** over phrases: with "Kebab" in the name, the keywords `near,doner,shawarma` already cover "kebab near", "doner kebab", "shawarma near" — spending bytes on `kebab near me,doner kebab` repeats words. (Combination behaviour is widely observed ASO practice; Apple only documents that keywords, name and company name are searched.)
- Balance popular, competitive terms ("food", "restaurant") with specific, low-competition ones ("doner", "falafel").
- Localize keywords per storefront — not a literal translation of English; use what locals search.
- Each localization has its own 100 bytes. Several storefronts index more than one language (e.g. the U.S. storefront also indexes Spanish (Mexico)), so a secondary localization can hold extra keywords — this is widely used ASO practice, not something Apple documents in the guidelines; label it as a heuristic if you suggest it.

## 4. In-App Purchases on the product page

- Up to **20** promoted IAPs/subscriptions shown (two sections), order is configurable.
- Each needs: display name (**≤30 chars** in App Store Connect; include duration for subscriptions; avoid generic names like "100 gems" — tie it to the app), description (**≤45 chars**; clear benefit), and a **1024×1024** promotional image (see `specs.md` §6).
- IAPs can appear in search results and on Today/Games/Apps tabs; tapping leads to the product page. Consumables don't appear in search.
- App must handle the purchase on launch (`SKPaymentTransactionObserver` / StoreKit 2 `PurchaseIntent`), presenting the payment sheet immediately.

## 5. In-App Events

| Field | Limit | Style |
|---|---|---|
| Event name | 30 | Title case; the event's actual name, not a tagline or CTA |
| Short description | 50 | Sentence case; shown on the card |
| Long description | 120 | Sentence case; details page; may mention rewards |

- Badges: Challenge, Competition, Live Event, Major Update, New Season, Premiere, Special Event (+ In-Game Offer, Now On Sale, Try Before You Buy for featured game offers in the Games app). Don't repeat the badge type in the name.
- Up to 31 days long; promotable up to 14 days before start; up to 15 approved and 10 published at once; submittable without a new app version.
- Event purpose (for recommendations, not shown): all users / attract new / keep active informed / bring back lapsed.
- Deep link (universal link preferred, no URL shorteners) must land on the event.
- Bad candidates: daily tasks/rewards, price-only promotions, general app awareness.
- Media specs: `specs.md` §4. Design guidance: `visual-assets.md`.

## 6. Localization

Localize: name, subtitle, keywords, description, promo text, What's New, screenshots (text overlays!), previews, creative assets. Tailor keywords to each market's values and search terms. If a localized preview is missing, the next best language is shown. For Portugal use **pt-PT** wording (e.g. "telemóvel", "ecrã", "perto de ti"), not pt-BR.

## 7. Custom product pages (CPP)

- Up to **70** extra product pages (iPhone/iPad), each with its own **URL** (`?ppid=…`).
- Vary screenshots, app previews, promotional text — and (iOS 27) creative assets like the header.
- Assign **keywords** so the CPP shows in search for those terms instead of the default page; each keyword combination must be unique to one page and match the page's intent.
- Optional **deep link** per page (iOS/iPadOS 18+) to open the matching in-app destination.
- Submitted for review independently of an app update; uploadable via the App Store Connect API.
- Use in Apple Ads (Today tab, Search tab, search result variations), StoreKit ads (`SKOverlay` `customProductPageIdentifier`), emails, social.
- Apple's stat: referring people to a CPP gives +2.5 pp conversion on average (156% vs the 1.6% default page average).
- Measure in App Analytics → Acquisition (impressions, downloads, conversion, retention, proceeds per paying user).

## 8. Product page optimization (PPO)

- Test **up to 3 treatments** vs the original: app icon, screenshots, app previews (and iOS 27 creative assets).
- Shown to a random share of iOS/iPadOS 15+ users; each person keeps seeing the same treatment.
- One test at a time, runs up to **90 days**, can't be edited once started. Name ≤ 64 chars.
- New treatment metadata needs App Review approval; tests without alternate icons can be submitted without a new app version. **Alternate icons must be in the shipped binary** (all variants).
- Apply a winner only after ≥ **90% confidence**; applying ends the test. Change one variable per treatment so the result is interpretable.

## 9. Ratings & reviews

- `SKStoreReviewController` / SwiftUI `requestReview` — the system shows the prompt **at most 3 times per 365 days**. Ask after a positive moment, never after an error.
- Respond to reviews in App Store Connect; the reviewer is notified and can update.
- Ratings are per territory; you can reset the summary rating when releasing a new version.
- iOS 27: LLM-generated **review summaries** appear on product pages in more storefronts.
