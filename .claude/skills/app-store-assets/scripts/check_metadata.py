#!/usr/bin/env python3
"""Lint App Store text metadata against Apple's limits and review rules (Oct 2026).

Usage:
    python3 check_metadata.py metadata.json [--json] [--banned "brand1,brand2"]
    python3 check_metadata.py --template > metadata.json

Input: one localization object, or {"localizations": [obj, obj, ...]}.
Every field is optional — only the ones present are checked.

    {
      "locale": "en-US",
      "company_name": "Lucas",                 # developer/seller name (already searchable)
      "category": "Food & Drink",
      "kids_category": false,
      "has_iap": true,                          # app has IAP/subscriptions → disclosure check
      "name": "...",                            # 2–30 chars
      "subtitle": "...",                        # ≤ 30
      "promotional_text": "...",                # ≤ 170
      "description": "...",                     # ≤ 4000, plain text
      "keywords": "a,b,c",                      # ≤ 100 BYTES, comma-separated
      "whats_new": "...",                       # ≤ 4000
      "copyright": "2026 Lucas",
      "screenshot_captions": ["...", "..."],    # text overlaid on screenshots / creative assets
      "iap": [{"name": "...", "description": "..."}],                  # 2–30 / ≤ 45
      "events": [{"name": "...", "short_description": "...", "long_description": "..."}]  # 30/50/120
    }

Severities: BLOCKER (App Store Connect limit or explicit App Review rule),
WARNING (Apple best practice / likely flag), TIP (optimisation). Rules marked
"heuristic" are common practice, not written Apple policy.

Exit code: 1 if any BLOCKER, else 0. No third-party dependencies.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata

LIMITS = {  # field: (min, max, unit)
    "name": (2, 30, "chars"),
    "subtitle": (0, 30, "chars"),
    "promotional_text": (0, 170, "chars"),
    "description": (0, 4000, "chars"),
    "keywords": (0, 100, "bytes"),
    "whats_new": (0, 4000, "chars"),
}
IAP_LIMITS = {"name": (2, 30), "description": (0, 45)}
EVENT_LIMITS = {"name": 30, "short_description": 50, "long_description": 120}

CATEGORIES = {
    "books", "business", "developer tools", "education", "entertainment", "finance", "food & drink", "food",
    "drink", "games", "graphics & design", "health & fitness", "health", "fitness", "lifestyle", "kids",
    "magazines & newspapers", "medical", "music", "navigation", "news", "photo & video", "photo", "video",
    "productivity", "reference", "shopping", "social networking", "social", "sports", "travel", "utilities",
    "weather", "stickers",
}
OTHER_PLATFORMS = [
    r"android", r"google\s*play", r"play\s*store", r"galaxy\s*store", r"app\s*gallery", r"huawei",
    r"windows\s*phone", r"\bapk\b", r"amazon\s*appstore", r"aptoide", r"f-?droid",
]
APPLE_AWARDS = [
    r"editor'?s'?\s*choice", r"app\s*of\s*the\s*day", r"game\s*of\s*the\s*day", r"apple\s*design\s*award",
    r"featured\s*by\s*apple", r"approved\s*by\s*apple", r"apple[-\s]*(?:recommended|endorsed|certified)",
]
SUPERLATIVES = [
    r"#\s*1\b", r"\bno\.?\s*1\b", r"\bnumber\s*one\b", r"\bbest\b", r"\btop[-\s]*rated\b", r"\bworld'?s\b",
    r"\bleading\b", r"\bmost\s+popular\b", r"\baward[-\s]*winning\b", r"\b(?:melhor|mejor|meilleur|beste?)\b",
    r"\bn\.?º\s*1\b",
]
PRICE = [r"[€$£¥₹]\s*\d+(?:[.,]\d+)?", r"\d+(?:[.,]\d+)?\s*[€$£¥₹]", r"\b\d+(?:[.,]\d+)?\s*(?:usd|eur|gbp|euros?|dollars?)\b",
         r"\d+\s*%\s*(?:off|desconto|discount)"]
DISCOUNT = [r"\b(?:discount|on sale|desconto|promo[cç][aã]o|half[-\s]price)\b"]
FREE = [r"\bfree\b", r"\bgr[aá]tis\b", r"\bgratuit[ao]?\b", r"\bkostenlos\b"]
KIDS = [r"\bfor\s+kids\b", r"\bfor\s+children\b", r"\bpara\s+crian[cç]as\b", r"\bpara\s+mi[uú]dos\b"]
URL = [r"https?://", r"\bwww\.", r"\b[\w-]+\.(?:com|net|org|io|app|pt|co|dev)\b"]
DEFAULT_BRANDS = [
    "uber eats", "ubereats", "glovo", "deliveroo", "just eat", "bolt food", "doordash", "grubhub", "tripadvisor",
    "yelp", "google maps", "waze", "instagram", "tiktok", "facebook", "whatsapp", "snapchat", "youtube", "netflix",
    "spotify", "chatgpt", "openai", "airbnb", "booking.com", "strava", "duolingo", "candy crush", "minecraft",
    "fortnite", "pokemon", "mcdonalds", "mcdonald's", "starbucks",
]
IAP_WORDS = re.compile(
    r"in-app purchase|purchase|subscription|subscribe|premium|\bpro\b|unlock|upgrade|paid|"
    r"compra|subscri[cç][aã]o|assinatura|desbloque", re.I)
GENERIC_WHATS_NEW = re.compile(
    r"^\W*(bug\s*fixes|improvements|performance|minor\s*fixes|stability|corre[cç][oõ]es|melhorias)", re.I)
EMOJI = re.compile("[\U0001F000-\U0001FAFF☀-➿️]")
ACRONYMS = {"GPS", "AR", "VR", "USA", "NBA", "NFL", "PDF", "API", "FAQ", "HD", "4K", "UEFA", "FIFA", "BBQ", "DIY"}
CTA_START = re.compile(r"^\s*(watch|join|play|download|get|tap|click|try|start|register|sign\s*up|vem|joga|"
                       r"descarrega|junta-te|participa)\b", re.I)
EVENT_BADGES = re.compile(r"\b(challenge|competition|live event|major update|new season|premiere|special event)\b",
                          re.I)

TEMPLATE = {
    "localizations": [
        {
            "locale": "en-US",
            "company_name": "Your Name",
            "category": "Food & Drink",
            "kids_category": False,
            "has_iap": False,
            "name": "",
            "subtitle": "",
            "promotional_text": "",
            "description": "",
            "keywords": "",
            "whats_new": "",
            "copyright": "2026 Your Name",
            "screenshot_captions": [],
            "iap": [],
            "events": [],
        }
    ]
}


class Findings:
    def __init__(self, locale):
        self.locale = locale
        self.rows = []

    def add(self, sev, field, msg, rule=""):
        self.rows.append({"locale": self.locale, "severity": sev, "field": field, "message": msg, "rule": rule})


def length(text, unit):
    return len(text.encode("utf-8")) if unit == "bytes" else len(text)


def find(patterns, text):
    hits = []
    for p in patterns:
        for m in re.finditer(p, text, re.I):
            hits.append(m.group(0).strip())
    return sorted(set(hits), key=str.lower)


def words(text):
    norm = unicodedata.normalize("NFKC", text.lower())
    return [w for w in re.split(r"[^\w'-]+", norm) if w]


def check_content(f: Findings, field, text, *, visual=False, kids_ok=False, banned=(), event=False):
    """Rules that apply to any piece of customer-facing text."""
    strict = field in ("name", "subtitle", "keywords") or visual  # 2.3.7: no prices/terms in these
    prominent = strict or event or field == "promotional_text"
    if hits := find(OTHER_PLATFORMS, text):
        f.add("BLOCKER", field, f"Mentions another platform/marketplace: {', '.join(hits)}", "2.3.10")
    if hits := find(APPLE_AWARDS, text):
        f.add("BLOCKER", field, f"Apple award/endorsement wording: {', '.join(hits)}", "5.2.4 / asset best practices")
    if strict and (hits := find(DISCOUNT, text)):
        f.add("BLOCKER", field, f"Discount/sale term: {', '.join(hits)}", "2.3.7 / asset best practices")
    if hits := find(PRICE, text):
        if strict or event:
            f.add("BLOCKER", field, f"Price/discount term: {', '.join(hits)}", "2.3.7")
        elif field == "promotional_text":
            f.add("WARNING", field, f"Specific price/discount: {', '.join(hits)} — mention a sale without an amount; "
                                    "prices vary by storefront", "product page guidance")
        else:
            f.add("WARNING", field, f"Specific price/discount: {', '.join(hits)} — Apple asks you not to include "
                                    "prices (they vary per region)", "product page guidance")
    if strict and (hits := find(FREE, text)):
        f.add("WARNING", field, f"Pricing term '{hits[0]}' in {field} — pricing information isn't allowed here",
              "2.3.7")
    if hits := find(SUPERLATIVES, text):
        sev = "WARNING" if prominent else "TIP"
        f.add(sev, field, f"Unverifiable claim: {', '.join(hits)} — only state what you can prove",
              "2.3.7 / asset best practices")
    if not kids_ok and (hits := find(KIDS, text)):
        f.add("WARNING", field, f"'{hits[0]}' is reserved for the Kids category", "2.3.8 / 5.1.4")
    if (strict or event) and (hits := find(URL, text)):
        f.add("WARNING" if not visual else "BLOCKER", field, f"URL in {field}: {', '.join(hits)}",
              "asset best practices" if visual else "2.3.7")
    if visual and re.search(r"©|\(c\)", text, re.I):
        f.add("WARNING", field, "Copyright symbol in a visual asset", "asset best practices")
    low = text.lower()
    for b in banned:
        if re.search(r"(?<!\w)" + re.escape(b.lower()) + r"(?!\w)", low):
            f.add("WARNING", field, f"Possible third-party trademark '{b}' — only with permission; never a "
                                    "competitor's name in keywords", "2.3.7 / 5.2.1")
    if re.search(r"\biphone app\b", text, re.I):
        f.add("TIP", field, "Say 'App name for iPhone', not 'iPhone app name'", "Marketing guidelines")
    if re.search(r"\bapple app store\b|\bat the app store\b", text, re.I):
        f.add("TIP", field, "Write 'on the App Store' (not 'Apple App Store' / 'at the App Store')",
              "Marketing guidelines")


def check_limits(f: Findings, field, text):
    lo, hi, unit = LIMITS[field]
    n = length(text, unit)
    if n > hi:
        f.add("BLOCKER", field, f"{n} {unit} — max {hi}", "App Store Connect limit")
    elif lo and n < lo:
        f.add("BLOCKER", field, f"{n} {unit} — min {lo}", "App Store Connect limit")
    return n


def check_keywords(f: Findings, kw, loc, banned):
    if not kw:
        return
    if re.search(r",\s", kw):
        f.add("WARNING", "keywords", "Spaces after commas waste bytes — use 'a,b,c'", "product page guidance")
    terms = [t.strip() for t in kw.split(",")]
    if any(t == "" for t in terms):
        f.add("WARNING", "keywords", "Empty term (double or trailing comma)", "product page guidance")
    terms = [t for t in terms if t]
    lower = [t.lower() for t in terms]
    for t in terms:
        if len(t) <= 2:
            f.add("WARNING", "keywords", f"'{t}' — each keyword must be longer than two characters",
                  "App Store Connect")
        if re.search(r"[#@]", t):
            f.add("WARNING", "keywords", f"'{t}' — special characters carry no extra weight", "product page guidance")
    dups = sorted({t for t in lower if lower.count(t) > 1})
    if dups:
        f.add("WARNING", "keywords", f"Duplicate terms: {', '.join(dups)}", "product page guidance")
    kw_words = []
    for t in lower:
        kw_words += words(t)
    seen = set()
    rep = sorted({w for w in kw_words if w in seen or seen.add(w)})
    if rep:
        f.add("TIP", "keywords", f"Words repeated across phrases: {', '.join(rep)} — single words combine with each "
                                 "other and with the name/subtitle, so each word only needs to appear once "
                                 "(heuristic)", "ASO practice")
    indexed = set(words(loc.get("name", ""))) | set(words(loc.get("subtitle", ""))) | \
        set(words(loc.get("company_name", "")))
    wasted = sorted({w for w in kw_words if w in indexed and len(w) > 2})
    if wasted:
        f.add("WARNING", "keywords", f"Already in name/subtitle/company name: {', '.join(wasted)} — already "
                                     "searchable, remove to free bytes", "App Store Connect / product page guidance")
    if "app" in kw_words or "apps" in kw_words:
        f.add("WARNING", "keywords", "Don't use the word 'app'", "product page guidance")
    cats = sorted({t for t in lower if t in CATEGORIES})
    if cats:
        f.add("WARNING", "keywords", f"Category names: {', '.join(cats)} — don't use them", "product page guidance")
    wset = set(kw_words)
    plurals = sorted({w for w in wset if len(w) > 3 and w.endswith("s") and w[:-1] in wset})
    if plurals:
        f.add("WARNING", "keywords", f"Plural of a word already present: {', '.join(plurals)}",
              "product page guidance")
    joined = " , ".join(lower)
    for b in banned:
        if re.search(r"(?<!\w)" + re.escape(b.lower()) + r"(?!\w)", joined):
            f.add("BLOCKER", "keywords", f"Third-party/competitor name '{b}'", "2.3.7")


def lint(loc, banned):
    f = Findings(loc.get("locale", "default"))
    kids_ok = bool(loc.get("kids_category"))
    counts = {}
    for field in ("name", "subtitle", "promotional_text", "description", "keywords", "whats_new"):
        text = loc.get(field)
        if text is None:
            continue
        counts[field] = check_limits(f, field, text)
        if field != "keywords":
            check_content(f, field, text, kids_ok=kids_ok, banned=banned)
    if (kw := loc.get("keywords")) is not None:
        check_content(f, "keywords", kw, kids_ok=kids_ok, banned=())
        check_keywords(f, kw, loc, banned)

    for field in ("name", "subtitle"):
        text = loc.get(field) or ""
        if EMOJI.search(text):
            f.add("WARNING", field, "Emoji in the name/subtitle — frequently rejected (heuristic)", "2.3.7 practice")
        caps = [w for w in re.findall(r"\b[A-Z]{4,}\b", text) if w not in ACRONYMS]
        if caps:
            f.add("TIP", field, f"All-caps words: {', '.join(caps)}", "style")
    if loc.get("name") and loc.get("subtitle"):
        shared = (set(words(loc["name"])) & set(words(loc["subtitle"]))) - {"a", "the", "de", "e", "o", "and", "for"}
        if shared:
            f.add("TIP", "subtitle", f"Repeats words from the name: {', '.join(sorted(shared))} — use the 30 chars "
                                     "for new value/keywords", "ASO practice")

    desc = loc.get("description")
    if desc is not None:
        if re.search(r"<\s*/?\s*(b|i|p|br|ul|li|a|strong|em)\b[^>]*>", desc, re.I):
            f.add("BLOCKER", "description", "HTML tags — the description is plain text only", "App Store Connect")
        first = re.split(r"(?<=[.!?])\s|\n", desc.strip(), maxsplit=1)[0] if desc.strip() else ""
        if first and len(first) > 170:
            f.add("TIP", "description", f"First sentence is {len(first)} chars — it's what people read before "
                                        "'more'; make it short and specific", "product page guidance")
        if loc.get("has_iap") and not IAP_WORDS.search(desc):
            f.add("WARNING", "description", "App has IAP/subscriptions but the description never says which features "
                                            "require a purchase", "2.3.2")
    wn = loc.get("whats_new")
    if wn is not None and GENERIC_WHATS_NEW.search(wn) and len(wn) < 80:
        f.add("TIP", "whats_new", "Generic text is only OK for bug-fix/performance releases — list real "
                                  "features if this version adds any", "2.3.12")
    cr = loc.get("copyright")
    if cr and re.search(r"©|\(c\)", cr, re.I):
        f.add("WARNING", "copyright", "Remove '©' — App Store Connect adds it automatically", "App Store Connect")

    for i, cap in enumerate(loc.get("screenshot_captions") or [], 1):
        field = f"caption {i}"
        check_content(f, field, cap, visual=True, kids_ok=kids_ok, banned=banned)
        if len(cap.split()) > 8:
            f.add("TIP", field, f"{len(cap.split())} words — keep captions short (≤ ~6 words) so they read at "
                                "thumbnail size (heuristic)", "asset best practices")
        if "!!" in cap or re.search(r"\b[A-Z]{5,}\b", cap):
            f.add("TIP", field, "Shouting (caps/!!) reads as an ad, not as the app", "style")

    for i, iap in enumerate(loc.get("iap") or [], 1):
        for key, (lo, hi) in IAP_LIMITS.items():
            text = iap.get(key)
            if text is None:
                continue
            n = len(text)
            if n > hi or n < lo:
                f.add("BLOCKER", f"iap {i} {key}", f"{n} chars — must be {lo}–{hi}" if lo else f"{n} chars — max {hi}",
                      "App Store Connect limit")
            check_content(f, f"iap {i} {key}", text, kids_ok=kids_ok, banned=banned)
        name = iap.get("name") or ""
        if re.fullmatch(r"\s*\d+\s+\w+\s*", name):
            f.add("TIP", f"iap {i} name", f"'{name}' is generic — tie it to your app (e.g. 'Treasure Chest of 100 "
                                          "Gems')", "Promoting IAPs")

    for i, ev in enumerate(loc.get("events") or [], 1):
        for key, hi in EVENT_LIMITS.items():
            text = ev.get(key)
            if text is None:
                continue
            if len(text) > hi:
                f.add("BLOCKER", f"event {i} {key}", f"{len(text)} chars — max {hi}", "App Store Connect limit")
            check_content(f, f"event {i} {key}", text, kids_ok=kids_ok, banned=banned, event=True)
            if "!!" in text or re.search(r"\b[A-Z]{4,}\b", text):
                f.add("WARNING", f"event {i} {key}", "No all-caps or repeated punctuation", "In-App Events guidance")
        name = ev.get("name") or ""
        if CTA_START.search(name):
            f.add("WARNING", f"event {i} name", "Event name reads as a call to action — use the event's actual name",
                  "In-App Events guidance")
        if EVENT_BADGES.search(name):
            f.add("TIP", f"event {i} name", "Repeats the badge type — the badge already shows it",
                  "In-App Events guidance")
    return f.rows, counts


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--template", action="store_true", help="print a starter metadata.json")
    ap.add_argument("--banned", default="", help="extra comma-separated competitor/brand names to flag")
    ap.add_argument("--no-default-brands", action="store_true", help="don't flag the built-in brand list")
    args = ap.parse_args()

    if args.template:
        print(json.dumps(TEMPLATE, indent=2, ensure_ascii=False))
        return
    if not args.file:
        ap.error("metadata.json required (or --template)")
    with open(args.file, encoding="utf-8") as fh:
        data = json.load(fh)
    locs = data.get("localizations", [data]) if isinstance(data, dict) else data
    banned = [] if args.no_default_brands else list(DEFAULT_BRANDS)
    banned += [b.strip() for b in args.banned.split(",") if b.strip()]

    all_rows, all_counts = [], {}
    for loc in locs:
        rows, counts = lint(loc, banned)
        all_rows += rows
        all_counts[loc.get("locale", "default")] = counts

    order = {"BLOCKER": 0, "WARNING": 1, "TIP": 2}
    all_rows.sort(key=lambda r: (r["locale"], order[r["severity"]]))
    blockers = sum(r["severity"] == "BLOCKER" for r in all_rows)

    if args.json:
        print(json.dumps({"counts": all_counts, "findings": all_rows, "blockers": blockers}, indent=2,
                         ensure_ascii=False))
        sys.exit(1 if blockers else 0)

    for locale, counts in all_counts.items():
        print(f"== {locale}")
        for field, n in counts.items():
            lo, hi, unit = LIMITS[field]
            mark = "✗" if n > hi or (lo and n < lo) else "✓"
            print(f"   {mark} {field:<17} {n:>4}/{hi} {unit}")
        rows = [r for r in all_rows if r["locale"] == locale]
        if not rows:
            print("   No issues found.")
        for r in rows:
            rule = f"  [{r['rule']}]" if r["rule"] else ""
            print(f"   {r['severity']:<7} {r['field']}: {r['message']}{rule}")
        print()
    print(f"{blockers} blocker(s), {sum(r['severity'] == 'WARNING' for r in all_rows)} warning(s), "
          f"{sum(r['severity'] == 'TIP' for r in all_rows)} tip(s).")
    sys.exit(1 if blockers else 0)


if __name__ == "__main__":
    main()
