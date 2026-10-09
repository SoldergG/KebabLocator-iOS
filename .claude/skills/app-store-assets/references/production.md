# Production — capturing and exporting assets

Practical commands for a Mac with Xcode. Simulator screenshots of the right device already have the exact pixel size App Store Connect expects, which is the easiest way to avoid "invalid size" upload errors.

## Contents
1. Which Simulator for which size
2. Clean status bar
3. Screenshots
4. Recording an app preview
5. Exporting the preview with ffmpeg
6. Creative asset / event video export
7. Validate before uploading

---

## 1. Which Simulator for which size

| Target slot | Simulator | Output |
|---|---|---|
| iPhone 6.9" | iPhone 17 Pro Max (or 16 Pro Max) | 1320×2868 |
| iPhone 6.1" Dynamic Island medium | iPhone 17 / 17 Pro (or 16 Pro) | 1206×2622 |
| iPhone 6.1" (older accepted size) | iPhone 16 / 15 / 15 Pro / 14 Pro | 1179×2556 |
| iPhone 6.5" | iPhone 11 Pro Max / XS Max (if installed) | 1242×2688 |
| iPad 13" | iPad Pro 13-inch (M5/M4) | 2064×2752 |
| iPad 11" | iPad Pro 11-inch (M5/M4) | 1668×2420 |

List what's installed: `xcrun simctl list devices available`.

## 2. Clean status bar

Apple's marketing guidelines ask for full Wi-Fi/cellular and full battery. Simulator can force this (run after the device boots, re-run after a reboot):

```bash
xcrun simctl status_bar booted override \
  --time "9:41" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --operatorName "" \
  --batteryState charged --batteryLevel 100
# undo:
xcrun simctl status_bar booted clear
```

## 3. Screenshots

```bash
# Light and dark captures of the current screen
xcrun simctl ui booted appearance light
xcrun simctl io booted screenshot --type=png "01-home-light.png"
xcrun simctl ui booted appearance dark
xcrun simctl io booted screenshot --type=png "01-home-dark.png"

# Other languages: launch the app in a given locale
xcrun simctl launch booted com.example.app -AppleLanguages "(pt-PT)" -AppleLocale pt_PT
```

Simulator PNGs have no alpha channel issues, but anything that went through a design tool might: export as PNG without transparency (or JPEG). Strip alpha with Pillow if needed:

```python
from PIL import Image
im = Image.open("in.png"); bg = Image.new("RGB", im.size, (0, 0, 0))
bg.paste(im, mask=im.split()[-1] if im.mode in ("RGBA", "LA") else None); bg.save("out.png")
```

For repeatable multi-language screenshot runs, a UI test that navigates to each screen and calls `XCUIScreen.main.screenshot()` (or fastlane `snapshot`) beats manual capture.

Composing captions: any design tool works (Figma, Sketch, Pixelmator, Keynote), as long as the export is **exactly** one of the accepted sizes. Build the canvas at the final size (e.g. 1320×2868) rather than scaling afterwards.

## 4. Recording an app preview

```bash
# Simulator (stop with Ctrl-C)
xcrun simctl io booted recordVideo --codec=h264 --force raw-preview.mov
```

Or record a real device with QuickTime Player (File → New Movie Recording → choose the iPhone as camera). Real device = real performance and haptic-free smooth scrolling; Simulator = clean status bar control. Keep the raw capture longer than needed and cut in iMovie / Final Cut Pro, then export with ffmpeg so the specs are exact.

## 5. Exporting the preview with ffmpeg

Target: **886×1920** (modern iPhones, portrait), ≤30 fps, H.264 High ≤ L4.0, 10–12 Mbps, stereo AAC 256 kbps 44.1/48 kHz, 15–30 s, ≤500 MB.

```bash
# iPhone portrait preview from a Simulator/QuickTime recording
ffmpeg -y -i edited.mov \
  -vf "scale=886:1920:flags=lanczos,setsar=1,fps=30,format=yuv420p" \
  -c:v libx264 -profile:v high -level:v 4.0 -preset slow \
  -b:v 11M -maxrate 12M -bufsize 24M \
  -c:a aac -b:a 256k -ar 44100 -ac 2 \
  -t 30 -movflags +faststart preview-886x1920.mp4
```

If the edit has **no audio track**, add a silent stereo track (App Store Connect's preview spec lists audio as stereo AAC with "all tracks enabled"; a silent track avoids ambiguity — this is a safety measure, not an explicit Apple requirement):

```bash
ffmpeg -y -i edited.mov -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
  -map 0:v:0 -map 1:a:0 -shortest \
  -vf "scale=886:1920:flags=lanczos,setsar=1,fps=30,format=yuv420p" \
  -c:v libx264 -profile:v high -level:v 4.0 -b:v 11M -maxrate 12M -bufsize 24M \
  -c:a aac -b:a 256k -ar 44100 -ac 2 -t 30 -movflags +faststart preview-886x1920.mp4
```

Other targets: swap the size — landscape iPhone `1920:886`, iPad `1200:1600` / `1600:1200`, Mac/Apple TV `1920:1080`.

Source aspect check: modern iPhones are ~19.5:9 and 886×1920 is ~0.4615 — a 1320×2868 recording (0.4603) scales with negligible distortion. For a mismatched source, use `scale=886:1920:force_original_aspect_ratio=increase,crop=886:1920` instead.

Poster frame: defaults to 5 s — make sure the frame at 0:05 is strong, or set it in Media Manager before submitting.

## 6. Creative asset / event video export

Product page header (21:9, 3840×1646), search results (3:2, e.g. 2880×1920), event card (16:9) / details (9:16). 30 or 60 fps, 5–30 s (header/search) or 15–30 s (events). Loop seamlessly — end on the frame you start with, or crossfade the last 0.5 s into the first.

```bash
ffmpeg -y -i master.mov \
  -vf "scale=3840:1646:force_original_aspect_ratio=increase,crop=3840:1646,fps=30,format=yuv420p" \
  -c:v libx264 -profile:v high -preset slow -crf 18 -an -t 20 -movflags +faststart header-3840x1646.mp4
```

(Header/search videos are muted by default; add audio only if you designed it as an optional texture layer.)

## 7. Validate before uploading

```bash
python3 <skill>/scripts/check_assets.py ./AppStore/ --ipad
```

It reports, per file: the App Store slot(s) the size fits, alpha channels, wrong formats, and — with ffprobe — duration, fps, codec, audio and file size against the preview/creative/event rules, plus whether the required screenshot sizes are covered.
