---
name: Duty Guard
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#44474f'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#747780'
  outline-variant: '#c4c6d0'
  surface-tint: '#455e91'
  primary: '#00163a'
  on-primary: '#ffffff'
  primary-container: '#0b2a5b'
  on-primary-container: '#7a93ca'
  inverse-primary: '#aec6ff'
  secondary: '#855300'
  on-secondary: '#ffffff'
  secondary-container: '#fea619'
  on-secondary-container: '#684000'
  tertiary: '#001c10'
  on-tertiary: '#ffffff'
  tertiary-container: '#003320'
  on-tertiary-container: '#00a874'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#aec6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#2c4678'
  secondary-fixed: '#ffddb8'
  secondary-fixed-dim: '#ffb95f'
  on-secondary-fixed: '#2a1700'
  on-secondary-fixed-variant: '#653e00'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
  plate-display:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '800'
    lineHeight: 28px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-lg: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

This design system establishes an authoritative, mission-critical mobile utility tailored for on-field traffic enforcement personnel across India. The aesthetic bridges institutional authority with civic transparency: disciplined, highly utilitarian, and instantly legible under harsh outdoor sunlight and chaotic roadside environments.

The visual ethos blends **Modern Civic Utility** with **Tactile Field Optimization**:
- **Legibility First:** High-contrast interfaces optimized to defeat glare and direct solar wash.
- **Mission Critical Ergonomics:** Generous hit targets (minimum 48px to 56px) accommodating single-handed use, active movement, and gloved or rain-slicked fingers.
- **Unambiguous Status Architecture:** Immediate, unmistakable status communication to prevent split-second verification errors during roadside inspections.

## Colors

The palette is engineered for institutional trust, immediate cognitive triage, and strict outdoor contrast adherence (WCAG AAA for text and core interactive elements).

### Core Palette
- **Deep Navy (`#0B2A5B`):** The institutional primary. Anchors top app bars, primary action buttons, credential tags, and active navigation states.
- **Saffron Amber (`#F59E0B`):** Accent and caution indicator. Used for warning badges, pending challans, expiring vehicle documents (within 15–30 days), and secondary highlights.
- **Valid Emerald (`#10B981`):** Conveys active, authentic, clean records (valid RC, active insurance, clear PUC).
- **Violation Crimson (`#EF4444`):** Represents impound alerts, stolen flags, lapsed insurance, or direct violation processing.
- **Charcoal Deep (`#0F172A`):** High-contrast neutral for all primary labels, headers, license plate strings, and critical data points.

### Background & Surface Tiers
- **Canvas Base:** `#F8FAFC` (Slate 50) provides a soft, glare-reducing foundation.
- **Surface Elevation 1 (Cards):** `#FFFFFF` pure white to provide maximum contrast against slate backdrops.
- **Surface Elevation 2 (Dividers / Insets):** `#F1F5F9` (Slate 100) for nested input containers, camera preview framing, and table header rows.
- **Muted Text Neutral:** `#64748B` (Slate 500) for secondary metadata, timestamps, and statutory fine clauses.

## Typography

Inter serves across all hierarchy tiers. Its neutral grotesque geometry, generous x-height, and open apertures remain readable on budget screens under heavy glare.

- **Data Density Handling:** Dynamic numerical and identification details (e.g., DL Numbers, RC Numbers, Challan IDs) must utilize tabular numbers (`font-variant-numeric: tabular-nums`) to prevent optical jitter during live scanner updates.
- **Plate Display Role (`plate-display`):** Explicitly designed for Indian HSRP (High Security Registration Plate) representation. Always rendered in all-caps with generous character spacing to avoid character ambiguity (such as differentiating `8` vs `B` and `0` vs `D`).
- **Uppercase Labels (`label-sm`):** Reserved for statutory validation badges, status tags, and legal category headers.

## Layout & Spacing

Field operations require fluid single-column structures optimized for portrait handheld devices with quick thumb access:
- **Base Rhythm:** Built strictly upon an 8pt spatial grid, with 4pt micro-steps for tight metadata stacks.
- **Touch Perimeter:** All primary inspection triggers, search fields, and camera capture controls enforce a minimum hit target dimension of 48px × 48px (ideally 56px height for primary actions).
- **Viewport Safe Regions:** Critical quick-action buttons (e.g., "Issue Challan", "Scan Plate", "Verify DL") adhere to bottom thumb zones with safe-area spacing above mobile navigation docks.
- **Breakpoints:**
  - Phone (`< 600px`): Single-column full-width cards with `margin: 1rem` (16px).
  - Rugged Tablet / POS Device (`600px - 1024px`): Dual-column split view (Live Camera Feed / OCR data left, Verification & Challan Issuance right) with `margin: 1.5rem` (24px) and `gutter: 1rem` (16px).

## Elevation & Depth

To maintain high visibility under direct sunlight, depth relies on structural tonal boundaries supplemented by soft, broad-diffusion ambient shadows. Harsh or dark drop shadows are avoided as they make low-brightness displays muddy.

- **Level 0 (Flat / Canvas):** `#F8FAFC`. Used for global backgrounds and inactive screen regions.
- **Level 1 (Cards & Data Panels):** `#FFFFFF` with a 1px border (`#E2E8F0`) and subtle ambient shadow: `0 2px 4px -1px rgba(15, 23, 42, 0.04), 0 4px 6px -1px rgba(15, 23, 42, 0.06)`. This ensures distinct card isolation without harsh contrasts.
- **Level 2 (Interactive Floating Actions / Bottom Sheets):** `#FFFFFF` with `0 10px 15px -3px rgba(11, 42, 91, 0.08), 0 4px 6px -4px rgba(11, 42, 91, 0.04)`. Tints the shadow with the primary deep navy tone for crisp ambient separation.
- **Level 3 (Modal Overlays & Critical Alerts):** Deep backdrop mask (`rgba(15, 23, 42, 0.65)`) paired with elevated cards: `0 20px 25px -5px rgba(15, 23, 42, 0.15)`.

## Shapes

The design system standardizes on a balanced, approachable 12px (`0.75rem`) border radius for standard structural cards, delivering a modern civic feel while maintaining structural authority.

- **Cards & Data Groups:** Exactly 12px radius (`rounded-md` equivalent to 0.75rem in this context), balancing space utilization with visual softness.
- **Interactive Buttons & Input Fields:** 10px to 12px radius, framing tap areas cleanly.
- **Badges, Status Chips, & Micro Pills:** Full pill radius (`9999px`) to visually differentiate quick status chips from tappable card surfaces.
- **Camera Scanning Reticle:** 16px corner notches with transparent center view for OCR plate detection.

## Components

### Buttons
- **Primary:** Deep navy (`#0B2A5B`) fill, white text (`#FFFFFF`), `label-lg` typography, height of 52px. Active state uses a deeper navy (`#071A38`).
- **Destructive / Impound:** Crimson (`#EF4444`) fill with pure white label for irreversible enforcement steps (e.g., "Seize Vehicle", "Log FIR").
- **Secondary / Actionable Neutral:** Surface white (`#FFFFFF`) with 1.5px border (`#CBD5E1`), charcoal text (`#0F172A`), min height 48px.
- **Tactile Feedback:** Buttons feature a subtle 0.98 scale-down on active press to verify tap completion in noisy traffic conditions.

### Status Chips & Badges
- **Valid (Green):** Background `#ECFDF5`, border `#A7F3D0`, text `#065F46`, paired with an explicit check icon.
- **Expired / Alert (Red):** Background `#FEF2F2`, border `#FECACA`, text `#991B1B`, paired with a hazard warning icon.
- **Expiring Soon / Pending (Amber):** Background `#FFFBEB`, border `#FDE68A`, text `#92400E`, accompanied by an hourglass or clock icon.
- **Layout:** Height 28px, pill-shaped (`border-radius: 9999px`), padding `0.25rem 0.75rem`, `label-sm` font.

### Cards & Record Panels
- **Standard Record Card:** Pure white background, 12px rounded corners, 1px perimeter border (`#E2E8F0`). Contains dedicated semantic sections separated by `#F1F5F9` divider lines.
- **HSRP Plate Display Card:** Surface tint `#F8FAFC`, dark charcoal 2px perimeter border mimicking the physical license plate, inner typography matching `plate-display` with an integrated "IND" badge on the left side.

### Input Fields & Search Bars
- **Vehicle / DL Lookup Field:** 54px height, `#FFFFFF` background, 2px border `#CBD5E1`, focusing to `#0B2A5B` with an outer glow.
- **Clear & OCR Action Buttons:** Embedded quick-action icons (e.g., license plate OCR camera trigger, clear text) with minimum 44px hit bounds inside the field wrapper.

### Verification Checklist & Radios
- **Touch Target:** Full-width card-style row (min height 56px) allowing one-tap selection anywhere across the item row.
- **Selected State:** Border color shifts to `#0B2A5B` with a subtle `#F8FAFC` background shift and an emphatic checked indicator.

### Field-Specific Components
- **Challan Fine Calculator:** Sticky bottom drawer displaying accumulated Motor Vehicles Act offense sections, real-time fine tally in Indian Rupee format (`₹`), and an instant print/share thermal receipt dispatch trigger.
- **Quick Evidence Capture:** Embedded square camera preview thumbnail strip allowing on-scene photo attachment (violation angle, driver, number plate) with instant optical validation status.