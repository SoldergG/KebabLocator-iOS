# App icon — design & production

Sources (fetched October 2026):
- HIG App icons: https://developer.apple.com/design/human-interface-guidelines/app-icons
- Icon Composer: https://developer.apple.com/icon-composer/
- Add an app icon (App Store Connect): https://developer.apple.com/help/app-store-connect/manage-app-information/add-an-app-icon
- WWDC25 "Say hello to the new look of app icons", WWDC26 "Icon Composer for Beginners Group Lab"

Specs table: `specs.md` §5.

## How icons work now (Liquid Glass)

iOS, iPadOS, macOS and watchOS icons are **layered**: a background layer + one or more foreground layers. The system adds Liquid Glass effects — specular highlights, refraction, translucency, shadows — that adapt to size, lighting and appearance and can change between OS versions. tvOS uses 2–5 parallax layers; visionOS a background + 1–2 layers rendered in 3D.

**Workflow:** draw foreground layers in your design tool → import into **Icon Composer** (bundled with Xcode) → set background (solid or gradient), placement, glass effects, groupings → annotate default / dark / mono (clear & tinted) variants → preview across platforms and OS versions → export the `.icon` and add it to the Xcode project. tvOS/visionOS: image stacks in the asset catalog (Parallax Previewer/Exporter from Apple Design Resources).

The icon ships **in the binary** — changing it needs a new app version. Alternate icons for PPO tests must also be in the binary.

## Layer rules

- **Square, unmasked layers** (rectangular for tvOS). The system applies corner/circle masks. Pre-masked layers break highlights and look jagged.
- **Clearly defined edges** on foreground shapes — no soft/feathered edges.
- **Vary opacity** in foreground layers for depth; import fully opaque layers and tune transparency in Icon Composer.
- **Background**: prefer Icon Composer's solid/gradient; if importing one, it must be full-bleed and opaque. Gradients must react well to system lighting.
- **Prefer vectors** (SVG/PDF); outline text. PNG for mesh gradients/raster art (lossless).
- **Don't bake in effects** — no specular highlights, drop shadows between layers, bevels, blurs, glows. The system's effects are dynamic; yours are static and clash. If you must, test in Icon Composer, Simulator/Device Hub and on device.
- Group layers in Icon Composer to apply glass effects at group level.

## Design rules

- **Simplicity** — one concept that captures the app's essence, minimal shapes, simple background. You don't need to fill the canvas.
- **Centered** primary content (critical for circular visionOS/watchOS masks). Use the grids in Apple's production templates.
- **Filled, overlapping shapes** with transparency/blur read as depth; outlined shapes look flat.
- **Text only if essential** to the brand — it isn't accessible or localizable and is tiny. A single mnemonic letter can work. Never "Play", "Watch", "New", "For visionOS".
- **Illustration over photo**; don't replicate UI components or screenshots. Avoid very thin lines and sharp corners (they vanish at small sizes).
- **No Apple hardware replicas.** No other developer's icon/brand (4.1(c)). Must be 4+ (2.3.8).
- **Consistent across platforms** so people recognize it everywhere.
- **watchOS**: avoid black backgrounds (blends into the display) — lighten them.
- **visionOS**: no background shapes meant to look like holes/concave areas.
- **tvOS**: keep a safe zone; foreground layers get cropped more during parallax; text above other layers.

## Appearances (iOS / iPadOS / macOS)

People choose **default, dark, clear (light/dark) or tinted (light/dark)**. You can design each; the system generates any you don't provide.

- Keep the **same core features** across appearances — don't swap elements in and out.
- Dark: derive from the light icon; complementary, subdued colors; avoid excessively bright imagery; colored foreground on dark background gives best contrast.
- Clear and tinted are even more subdued — the shape must carry recognition on its own.
- **Alternate icons** (user-selectable in settings) each need their own dark/clear/tinted variants and are subject to App Review.

## Review checklist for an icon

- [ ] Recognizable at 29 pt / Spotlight size (shrink it to ~60 px and squint)
- [ ] Single focal concept, centered, survives circular mask
- [ ] No text (or one essential mnemonic), no photo, no UI screenshot
- [ ] Layers square, unmasked, crisp-edged; no baked shadows/glows
- [ ] Looks right in default, dark, clear, tinted (Icon Composer preview)
- [ ] Distinct from competitors and from Apple's own icons; no Apple hardware
- [ ] 4+ appropriate; rights to all artwork
- [ ] Matches the palette/tone of screenshots and creative assets
