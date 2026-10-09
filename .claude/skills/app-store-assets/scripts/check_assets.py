#!/usr/bin/env python3
"""Validate App Store image/video assets against Apple's official specs (Oct 2026).

Usage:
    python3 check_assets.py PATH [PATH ...] [--ipad] [--json]

PATH can be files or directories (searched recursively). For every image it
reports which App Store slot(s) the exact pixel size fits (screenshot sizes,
app icon, iOS 27 creative assets, In-App Event media, promoted IAP image) and
flags alpha channels / wrong formats. For every video it checks app preview,
creative asset and In-App Event video rules (needs `ffprobe` on PATH for
duration, fps, codec and audio checks; without it only the size is checked).

At the end it summarises whether the required screenshot sizes are covered.
Pass --ipad if the app runs on iPad (then a 13" iPad set is required).

Exit code: 1 if any BLOCKER was found, else 0.

No third-party dependencies. Image headers (PNG, JPEG) are parsed directly.
Specs: https://developer.apple.com/help/app-store-connect/reference/app-information/
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import struct
import subprocess
import sys
from collections import defaultdict
from fractions import Fraction

IMAGE_EXT = {".png", ".jpg", ".jpeg"}
VIDEO_EXT = {".mov", ".m4v", ".mp4"}
OTHER_IMAGE_EXT = {".heic", ".webp", ".gif", ".tif", ".tiff", ".bmp"}

# ---------------------------------------------------------------------------
# Screenshot slots: (group, label, [(w, h), ...] portrait sizes). Landscape is
# the same sizes swapped. Group ids feed the "required sizes" summary.
# ---------------------------------------------------------------------------
SCREENSHOTS = [
    ("iphone_duo", 'iPhone Duo (outer)', [(1398, 2034)]),
    ("iphone_duo", 'iPhone Duo (inner)', [(2007, 2853)]),
    ("iphone_di_large", 'iPhone 6.9" Dynamic Island large', [(1260, 2736), (1290, 2796), (1320, 2868)]),
    ("iphone_faceid_large", 'iPhone 6.5" Face ID large', [(1284, 2778), (1242, 2688)]),
    ("iphone_di_medium", 'iPhone 6.1" Dynamic Island medium', [(1179, 2556), (1206, 2622)]),
    ("iphone_faceid_medium", 'iPhone 5.8" Face ID medium', [(1170, 2532), (1125, 2436), (1080, 2340)]),
    ("iphone_55", 'iPhone 5.5" Home Button large', [(1242, 2208)]),
    ("iphone_47", 'iPhone 4.7" Home Button medium', [(750, 1334)]),
    ("iphone_40", 'iPhone 4" Home Button', [(640, 1096), (640, 1136)]),
    ("iphone_35", 'iPhone 3.5" Home Button', [(640, 920), (640, 960)]),
    ("ipad_13", 'iPad 13"', [(2064, 2752), (2048, 2732)]),
    ("ipad_129", 'iPad 12.9" (2nd gen)', [(2048, 2732)]),
    ("ipad_11", 'iPad 11"', [(1488, 2266), (1668, 2420), (1668, 2388), (1640, 2360)]),
    ("ipad_105", 'iPad 10.5"', [(1668, 2224)]),
    ("ipad_97", 'iPad 9.7"', [(1536, 2008), (1536, 2048), (768, 1004), (768, 1024)]),
]
# 4"/3.5"/9.7" landscape "without status bar" sizes aren't plain swaps.
EXTRA_LANDSCAPE = {
    "iphone_40": [(1136, 600)],
    "iphone_35": [(960, 600)],
    "ipad_97": [(2048, 1496), (1024, 748)],
}
FIXED_SCREENSHOTS = [
    ("mac", "Mac (16:10)", [(1280, 800), (1440, 900), (2560, 1600), (2880, 1800)]),
    ("appletv", "Apple TV", [(1920, 1080), (3840, 2160)]),
    ("visionpro", "Apple Vision Pro", [(3840, 2160)]),
    ("watch", "Apple Watch Ultra 4/3", [(422, 514)]),
    ("watch", "Apple Watch Ultra 2/Ultra", [(410, 502)]),
    ("watch", "Apple Watch Series 12/11/10", [(416, 496)]),
    ("watch", "Apple Watch Series 9/8/7", [(396, 484)]),
    ("watch", "Apple Watch Series 6/5/4/SE", [(368, 448)]),
    ("watch", "Apple Watch Series 3/2/1", [(312, 390)]),
]

PREVIEW_SIZES = {
    (886, 1920): 'App preview — iPhone 6.9"/6.5"/6.1"/5.8"/Duo (portrait)',
    (1920, 886): 'App preview — iPhone 6.9"/6.5"/6.1"/5.8"/Duo (landscape)',
    (1080, 1920): 'App preview — iPhone 5.5"/4" (portrait)',
    (1920, 1080): 'App preview — iPhone 5.5"/4" landscape, Mac, Apple TV',
    (750, 1334): 'App preview — iPhone 4.7" (portrait)',
    (1334, 750): 'App preview — iPhone 4.7" (landscape)',
    (1200, 1600): 'App preview — iPad 13"/12.9"/11"/10.5" (portrait)',
    (1600, 1200): 'App preview — iPad 13"/12.9"/11"/10.5" (landscape)',
    (900, 1200): 'App preview — iPad 12.9"/9.7" (portrait)',
    (1200, 900): 'App preview — iPad 12.9"/9.7" (landscape)',
    (3840, 2160): "App preview — Apple Vision Pro (landscape)",
}

MAX_BYTES = 500 * 1024 * 1024


def screenshot_matches(w: int, h: int):
    out = []
    for group, label, sizes in SCREENSHOTS:
        for pw, ph in sizes:
            if (w, h) == (pw, ph):
                out.append((group, f"Screenshot — {label} (portrait)"))
            elif (w, h) == (ph, pw):
                out.append((group, f"Screenshot — {label} (landscape)"))
        for lw, lh in EXTRA_LANDSCAPE.get(group, []):
            if (w, h) == (lw, lh):
                out.append((group, f"Screenshot — {label} (landscape, no status bar)"))
    for group, label, sizes in FIXED_SCREENSHOTS:
        if (w, h) in sizes:
            out.append((group, f"Screenshot — {label}"))
    # de-duplicate while keeping order
    seen, uniq = set(), []
    for m in out:
        if m not in seen:
            seen.add(m)
            uniq.append(m)
    return uniq


def in_range(w, h, lo, hi, ratio: Fraction):
    return Fraction(w, h) == ratio and lo[0] <= w <= hi[0] and lo[1] <= h <= hi[1]


def creative_image_matches(w: int, h: int, ext: str):
    out = []
    if (w, h) == (3840, 1646):
        out.append(("creative", "Creative asset — product page header 21:9"))
    if (w, h) == (5244, 2950):
        label = "Creative asset — 16:9 header/search results (universal)"
        out.append(("creative", label if ext == ".png" else label + " — must be .png"))
    if in_range(w, h, (1920, 1280), (3840, 2560), Fraction(3, 2)):
        out.append(("creative", "Creative asset — search results 3:2"))
    if in_range(w, h, (1920, 1080), (3840, 2160), Fraction(16, 9)):
        out.append(("event", "In-App Event card 16:9"))
    if in_range(w, h, (1080, 1920), (2160, 3840), Fraction(9, 16)):
        out.append(("event", "In-App Event details page 9:16"))
    if (w, h) == (1024, 1024):
        out.append(("icon", "App icon layer 1024×1024 (iOS/iPadOS/macOS/visionOS) or promoted IAP image"))
    if (w, h) == (1088, 1088):
        out.append(("icon", "watchOS app icon 1088×1088"))
    if (w, h) == (800, 480):
        out.append(("icon", "tvOS app icon layer 800×480"))
    return out


def creative_video_matches(w: int, h: int):
    out = []
    if (w, h) == (3840, 1646):
        out.append(("creative_header", "Creative video — product page header 21:9", 5, 30))
    if in_range(w, h, (1920, 1280), (3840, 2560), Fraction(3, 2)):
        out.append(("creative_search", "Creative video — search results 3:2", 5, 30))
    if in_range(w, h, (1920, 1080), (3840, 2160), Fraction(16, 9)):
        out.append(("event", "In-App Event card video 16:9", 15, 30))
    if in_range(w, h, (1080, 1920), (2160, 3840), Fraction(9, 16)):
        out.append(("event", "In-App Event details video 9:16", 15, 30))
    return out


# ---------------------------------------------------------------------------
# Image header parsing (no Pillow needed)
# ---------------------------------------------------------------------------
def read_png(path):
    with open(path, "rb") as f:
        if f.read(8) != b"\x89PNG\r\n\x1a\n":
            return None
        has_trns = False
        w = h = color_type = bit_depth = None
        icc = None
        while True:
            hdr = f.read(8)
            if len(hdr) < 8:
                break
            length, ctype = struct.unpack(">I4s", hdr)
            data = f.read(length) if ctype in (b"IHDR", b"iCCP", b"sRGB") else None
            if data is None:
                f.seek(length, 1)
            f.seek(4, 1)  # CRC
            if ctype == b"IHDR":
                w, h, bit_depth, color_type = struct.unpack(">IIBB", data[:10])
            elif ctype == b"tRNS":
                has_trns = True
            elif ctype == b"iCCP":
                icc = data.split(b"\x00", 1)[0].decode("latin-1", "replace")
            elif ctype == b"sRGB":
                icc = icc or "sRGB"
            elif ctype in (b"IDAT", b"IEND"):
                break
        alpha = color_type in (4, 6) or has_trns
        mode = {0: "Gray", 2: "RGB", 3: "Indexed", 4: "Gray+Alpha", 6: "RGBA"}.get(color_type, "?")
        return {"format": "PNG", "width": w, "height": h, "alpha": alpha, "mode": mode,
                "bit_depth": bit_depth, "profile": icc}


def read_jpeg(path):
    with open(path, "rb") as f:
        if f.read(2) != b"\xff\xd8":
            return None
        while True:
            b = f.read(1)
            while b and b != b"\xff":
                b = f.read(1)
            while b == b"\xff":
                b = f.read(1)
            if not b:
                return None
            marker = b[0]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                continue
            seg_len = struct.unpack(">H", f.read(2))[0]
            if marker in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF):
                _precision, h, w, comps = struct.unpack(">BHHB", f.read(6))
                mode = {1: "Gray", 3: "RGB/YCbCr", 4: "CMYK"}.get(comps, "?")
                return {"format": "JPEG", "width": w, "height": h, "alpha": False, "mode": mode,
                        "bit_depth": 8, "profile": None}
            f.seek(seg_len - 2, 1)


def sniff(path):
    with open(path, "rb") as f:
        head = f.read(12)
    if head.startswith(b"\x89PNG"):
        return "png"
    if head.startswith(b"\xff\xd8"):
        return "jpeg"
    if head[4:8] == b"ftyp":
        return "isobmff"
    return None


# ---------------------------------------------------------------------------
# Video probing via ffprobe
# ---------------------------------------------------------------------------
def ffprobe(path):
    exe = shutil.which("ffprobe")
    if not exe:
        return None
    try:
        out = subprocess.run(
            [exe, "-v", "error", "-print_format", "json", "-show_streams", "-show_format", path],
            capture_output=True, text=True, timeout=60, check=True,
        ).stdout
        return json.loads(out)
    except (subprocess.SubprocessError, json.JSONDecodeError):
        return None


def parse_rate(r):
    try:
        n, d = r.split("/")
        return float(n) / float(d) if float(d) else 0.0
    except (ValueError, AttributeError):
        return 0.0


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------
class Report:
    def __init__(self):
        self.items = []  # dicts: file, kind, info, matches, issues[(sev, msg)]

    def add(self, **kw):
        kw.setdefault("issues", [])
        kw.setdefault("matches", [])
        self.items.append(kw)
        return kw


def check_image(path, report):
    ext = os.path.splitext(path)[1].lower()
    kind = sniff(path)
    item = report.add(file=path, kind="image")
    if ext in OTHER_IMAGE_EXT:
        item["issues"].append(("BLOCKER", f"{ext} isn't accepted — export as .png or .jpg"))
        return
    info = read_png(path) if kind == "png" else read_jpeg(path) if kind == "jpeg" else None
    if not info or not info.get("width"):
        item["issues"].append(("BLOCKER", "Couldn't read image header — not a valid PNG/JPEG"))
        return
    item["info"] = info
    if (kind == "png" and ext not in (".png",)) or (kind == "jpeg" and ext not in (".jpg", ".jpeg")):
        item["issues"].append(("WARNING", f"Extension {ext} doesn't match the real format ({info['format']}) — rename it"))
    w, h = info["width"], info["height"]
    shots = screenshot_matches(w, h)
    creative = creative_image_matches(w, h, ext)
    item["matches"] = [m[1] for m in shots] + [m[1] for m in creative]
    item["groups"] = [m[0] for m in shots]
    if not item["matches"]:
        item["issues"].append(("BLOCKER", f"{w}×{h} doesn't match any App Store image size — {nearest_hint(w, h)}"))
    if info["alpha"] and (w, h) in ((1024, 1024), (1088, 1088), (800, 480)):
        item["issues"].append(("WARNING", f"Has an alpha channel ({info['mode']}) — fine for an Icon Composer "
                                          "foreground layer, but a promoted IAP image or icon background must be "
                                          "flattened, opaque RGB"))
    elif info["alpha"]:
        item["issues"].append(("BLOCKER", f"Has an alpha channel ({info['mode']}) — screenshots and creative assets "
                                          "can't include transparency; re-export flattened RGB"))
    if info["mode"] == "CMYK":
        item["issues"].append(("BLOCKER", "CMYK JPEG — export as RGB (sRGB or Display P3)"))
    if info["mode"] in ("Indexed",):
        item["issues"].append(("WARNING", "Indexed-color PNG — export as 24-bit RGB to avoid banding"))
    if any("must be .png" in m for m in item["matches"]):
        item["issues"].append(("BLOCKER", "The 16:9 5244×2950 creative asset is only accepted as .png"))


def nearest_hint(w, h):
    """Suggest the closest official screenshot size with the same orientation."""
    best = None
    portrait = h >= w
    for group, label, sizes in SCREENSHOTS:
        for pw, ph in sizes:
            cw, ch = (pw, ph) if portrait else (ph, pw)
            d = abs(cw - w) + abs(ch - h)
            if best is None or d < best[0]:
                best = (d, cw, ch, label)
    if best:
        return f"closest screenshot size is {best[1]}×{best[2]} ({best[3]})"
    return "see references/specs.md"


def check_video(path, report):
    ext = os.path.splitext(path)[1].lower()
    item = report.add(file=path, kind="video")
    size = os.path.getsize(path)
    probe = ffprobe(path)
    if size > MAX_BYTES:
        item["issues"].append(("BLOCKER", f"File is {size / 1024 / 1024:.0f} MB — max 500 MB"))
    if probe is None:
        item["issues"].append(("WARNING", "ffprobe not available/failed — install ffmpeg (brew install ffmpeg) "
                                          "for duration/fps/codec/audio checks"))
        return
    vstreams = [s for s in probe.get("streams", []) if s.get("codec_type") == "video"]
    astreams = [s for s in probe.get("streams", []) if s.get("codec_type") == "audio"]
    if not vstreams:
        item["issues"].append(("BLOCKER", "No video stream found"))
        return
    v = vstreams[0]
    w, h = int(v.get("width", 0)), int(v.get("height", 0))
    rot = 0
    for sd in v.get("side_data_list", []) or []:
        if "rotation" in sd:
            rot = abs(int(sd["rotation"])) % 180
    if str((v.get("tags") or {}).get("rotate", "0")) in ("90", "270"):
        rot = 90
    if rot == 90:
        w, h = h, w
        item["issues"].append(("WARNING", "Video relies on a rotation flag — re-encode with the pixels in the final "
                                          "orientation to be safe"))
    fps = parse_rate(v.get("avg_frame_rate")) or parse_rate(v.get("r_frame_rate"))
    dur = float(probe.get("format", {}).get("duration") or v.get("duration") or 0)
    codec = v.get("codec_name", "?")
    profile = v.get("profile", "")
    level = v.get("level")
    bitrate = int(probe.get("format", {}).get("bit_rate") or 0)
    item["info"] = {"width": w, "height": h, "fps": round(fps, 3), "duration": round(dur, 2), "codec": codec,
                    "profile": profile, "level": level, "bitrate_mbps": round(bitrate / 1e6, 2),
                    "audio": [f"{a.get('codec_name')} {a.get('channels')}ch {a.get('sample_rate')}Hz"
                              for a in astreams], "size_mb": round(size / 1024 / 1024, 1)}

    preview_label = PREVIEW_SIZES.get((w, h))
    creative = creative_video_matches(w, h)
    item["matches"] = ([preview_label] if preview_label else []) + [c[1] for c in creative]
    if not item["matches"]:
        item["issues"].append(("BLOCKER", f"{w}×{h} isn't an accepted app preview, creative asset or event video "
                                          "size — iPhone previews must be 886×1920 (or 1920×886)"))
        return

    if preview_label:
        p = []
        if ext not in VIDEO_EXT:
            p.append(("BLOCKER", f"{ext} not accepted — use .mov, .m4v or .mp4"))
        if codec not in ("h264", "prores"):
            p.append(("BLOCKER", f"Codec {codec} — app previews must be H.264 or ProRes 422 (HQ)"))
        if codec == "prores" and ext != ".mov":
            p.append(("BLOCKER", "ProRes previews must be .mov"))
        if codec == "h264":
            if profile and profile.lower() not in ("high", "main", "baseline", "constrained baseline"):
                p.append(("BLOCKER", f"H.264 profile '{profile}' — use High Profile, level ≤ 4.0"))
            if level and int(level) > 40:
                p.append(("BLOCKER", f"H.264 level {int(level) / 10:.1f} — max High Profile Level 4.0"))
            if bitrate and not (8e6 <= bitrate <= 14e6):
                p.append(("WARNING", f"Bit rate {bitrate / 1e6:.1f} Mbps — Apple targets 10–12 Mbps for H.264"))
        if fps > 30.01:
            p.append(("BLOCKER", f"{fps:.2f} fps — app previews max 30 fps"))
        if dur < 15:
            p.append(("BLOCKER", f"{dur:.2f} s — app previews must be at least 15 s"))
        if dur > 30.0:
            p.append(("BLOCKER", f"{dur:.2f} s — app previews must be at most 30 s (trim with -t 30)"))
        if not astreams:
            p.append(("WARNING", "No audio track — spec lists stereo AAC 256 kbps; add a silent stereo track to be safe "
                                 "(see references/production.md)"))
        for a in astreams:
            if a.get("codec_name") not in ("aac", "pcm_s16le", "pcm_s24le", "pcm_s32le", "pcm_s16be", "pcm_s24be"):
                p.append(("BLOCKER", f"Audio codec {a.get('codec_name')} — use AAC 256 kbps (or PCM for ProRes)"))
            if a.get("sample_rate") not in ("44100", "48000"):
                p.append(("BLOCKER", f"Audio sample rate {a.get('sample_rate')} Hz — use 44.1 or 48 kHz"))
            if int(a.get("channels") or 0) not in (1, 2) or (len(astreams) == 1 and int(a.get("channels") or 0) != 2):
                p.append(("BLOCKER", "Audio must be stereo (1 track × 2 ch, or 2 tracks × 1 ch)"))
        if p:
            item["issues"] += [(s, f"[preview] {m}") for s, m in p]

    for _group, label, dmin, dmax in creative:
        c = []
        if ext not in VIDEO_EXT:
            c.append(("BLOCKER", f"{ext} not accepted — use .mov, .m4v or .mp4"))
        if not (abs(fps - 30) < 0.05 or abs(fps - 60) < 0.05):
            c.append(("BLOCKER", f"{fps:.2f} fps — must be 30 or 60 fps"))
        if dur < dmin or dur > dmax:
            c.append(("BLOCKER", f"{dur:.2f} s — must be {dmin}–{dmax} s"))
        if c:
            short = label.split(" — ")[-1] if " — " in label else label
            item["issues"] += [(s, f"[{short}] {m}") for s, m in c]


def coverage(report, ipad):
    groups = defaultdict(int)
    for it in report.items:
        for g in it.get("groups", []) or []:
            groups[g] += 1
    notes = []
    if not groups:
        return notes, {}
    has_iphone = any(g.startswith("iphone") for g in groups)
    if has_iphone:
        if not groups.get("iphone_di_medium"):
            notes.append(("BLOCKER",
                          'No iPhone 6.1" Dynamic Island (medium) screenshot (1206×2622 or 1179×2556) — App Store '
                          'Connect: "To submit your app, you must provide screenshots for … iPhone with Dynamic '
                          'Island (medium display)"'))
        if not groups.get("iphone_di_large") and not groups.get("iphone_faceid_large"):
            notes.append(("BLOCKER",
                          'No 6.9" (1320×2868) or 6.5" (1284×2778 / 1242×2688) set — Face ID (large) is required '
                          "when Dynamic Island (large) isn't provided"))
        if not groups.get("iphone_di_large"):
            notes.append(("TIP", 'Add a 6.9" set (1320×2868) — it\'s the largest iPhone size and the best master'))
    if ipad and not groups.get("ipad_13"):
        notes.append(("BLOCKER", 'App runs on iPad but no iPad 13" screenshot (2064×2752 or 2048×2732)'))
    for g, n in groups.items():
        if n > 10:
            notes.append(("WARNING", f"{n} screenshots match group '{g}' — max 10 per device size per language "
                                     "(fine if they're for different localizations)"))
    return notes, dict(groups)


def collect(paths):
    files = []
    for p in paths:
        if os.path.isdir(p):
            for root, _dirs, names in os.walk(p):
                for n in sorted(names):
                    if n.startswith("."):
                        continue
                    ext = os.path.splitext(n)[1].lower()
                    if ext in IMAGE_EXT | VIDEO_EXT | OTHER_IMAGE_EXT:
                        files.append(os.path.join(root, n))
        elif os.path.isfile(p):
            files.append(p)
        else:
            print(f"warning: {p} not found", file=sys.stderr)
    return files


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="+")
    ap.add_argument("--ipad", action="store_true", help="the app runs on iPad (13\" set required)")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    report = Report()
    for f in collect(args.paths):
        ext = os.path.splitext(f)[1].lower()
        if ext in VIDEO_EXT:
            check_video(f, report)
        else:
            check_image(f, report)
    notes, groups = coverage(report, args.ipad)

    blockers = sum(1 for it in report.items for s, _ in it["issues"] if s == "BLOCKER") + \
        sum(1 for s, _ in notes if s == "BLOCKER")

    if args.json:
        print(json.dumps({"files": report.items, "coverage": [{"severity": s, "message": m} for s, m in notes],
                          "groups": groups, "blockers": blockers}, indent=2, default=str))
        sys.exit(1 if blockers else 0)

    if not report.items:
        print("No .png/.jpg/.jpeg/.mov/.m4v/.mp4 files found.")
        sys.exit(0)
    for it in report.items:
        info = it.get("info") or {}
        dims = f"{info.get('width')}×{info.get('height')}" if info.get("width") else "?"
        extra = ""
        if it["kind"] == "video" and info:
            extra = f" · {info['duration']}s · {info['fps']}fps · {info['codec']} · {info['bitrate_mbps']}Mbps · " \
                    f"audio: {', '.join(info['audio']) or 'none'} · {info['size_mb']}MB"
        elif info:
            extra = f" · {info['format']} {info['mode']}"
        status = "✗" if any(s == "BLOCKER" for s, _ in it["issues"]) else ("!" if it["issues"] else "✓")
        print(f"{status} {it['file']}  [{dims}{extra}]")
        for m in it["matches"]:
            print(f"    fits: {m}")
        for s, m in it["issues"]:
            print(f"    {s}: {m}")
    print("\nRequired screenshot coverage:")
    if not groups:
        print("    (no screenshots among these files — coverage not checked)")
    elif not notes:
        print("    ✓ all required sizes present")
    for s, m in notes:
        print(f"    {s}: {m}")
    print(f"\n{blockers} blocker(s).")
    sys.exit(1 if blockers else 0)


if __name__ == "__main__":
    main()
