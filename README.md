# Traffic Police Assistant (Parivahan Connect)

A modern, on-field traffic enforcement mobile application built with Flutter, designed for traffic police officers and field inspectors across India. Features on-device ANPR (Automatic Number Plate Recognition) OCR, VAHAN vehicle and driver license verification, instant MVA fine computation, dynamic UPI QR thermal receipts, offline citation queueing, and an institutional Command HQ Admin panel.

---

## 🌟 Key Features

- **🛡️ Multi-Factor Inspector Authentication:**
  - Whitelist validation for authorized traffic police personnel.
  - 6-digit OTP verification with timer and 3-attempt account lockout protection.
  - Fast-Pass 4-digit PIN (`8429`) & on-device Biometric (Fingerprint / Face ID) simulation.

- **📷 ANPR OCR Camera Scanner (Google ML Kit):**
  - High-precision optical scanning HUD with oscillating laser beam and reticle targeting.
  - Real-time heuristic parsing for Indian HSRP (High Security Registration Plates) across all 36 States/UTs and Bharat Series (`BH`).
  - Stolen Vehicle BOLO (Be On the Lookout) automatic detection and immediate crimson alert banner.
  - Quick test presets for common vehicle plates.

- **🔍 VAHAN & Driving License Integration:**
  - Tabbed search across Registration Number, Chassis Number, Engine Number, and Driving License Number.
  - Real-time validity tracking for statutory documents: RC, Insurance, PUC, Fitness, and Permits.
  - Driving License suspension checks and penalty points tallying.
  - One-tap vehicle impound/seizure flow with immutable tamper-evident audit logging.

- **🧾 Instant Challan Issuance & Digital Settlement:**
  - Motor Vehicles Act (MVA) offenses checklist with real-time fine calculation.
  - Officer auto-tagging, timestamping, and GPS location coordinates.
  - Thermal receipt generator with live UPI QR code (`qr_flutter`) for instant citizen payment settlement.
  - Cash and POS card settlement logging with WhatsApp/SMS receipt sharing.

- **📡 Zero-Signal Offline Field Mode:**
  - In-memory offline citation queue for remote or underground enforcement locations.
  - Automatic fallback when network is unavailable.
  - One-tap bulk sync to the central server when connectivity resumes.

- **🏛️ Command HQ Admin Dashboard:**
  - Institutional Grid HUD with live emergency broadcast alerts sent to POS field terminals.
  - Bento KPI grid (Today's Challans, Total Fines Assessed, On-Duty Officers, Active Hotspots).
  - Weekly enforcement inflow and spot recovery analytics.
  - Field officer fleet roster and whitelist management.

- **🌐 Bilingual Localization:**
  - Full dynamic switching between **English** and **हिन्दी (Hindi)**.

---

## 📱 Tech Stack & Architecture

- **Framework:** Flutter (Channel stable, Dart 3)
- **Architecture:** Clean Layered Architecture (`Domain` → `Data` → `Presentation`)
- **Backend / Auth:** Supabase (`supabase_flutter`) with offline-first repositories
- **OCR Engine:** Google ML Kit Text Recognition with desktop/web simulator fallback
- **Design System:** Custom theme inspired by police tactical HUDs:
  - Deep Navy (`#0B2A5B`), Saffron Amber (`#F59E0B`), Valid Emerald (`#10B981`), Crimson Alert (`#EF4444`)
  - Typography: Google Fonts Inter with tabular figures
  - Custom `MobileDeviceFrame` for responsive desktop/web viewports

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.4.0)
- Google Chrome (for web execution) or Android Studio (for native Android builds)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/palanshujayprakash/traffic_police_app.git
   cd traffic_police_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (with mobile device frame):**
   ```bash
   flutter run -d chrome
   ```

4. **Run on Phone via Local Wi-Fi:**
   ```bash
   flutter run -d chrome --web-port=8080 --web-hostname=0.0.0.0
   ```
   Open `http://<YOUR_LOCAL_IP>:8080` in your mobile browser.

---

## 🧪 Testing & Code Quality

Run the test suite across all 8 test modules:
```bash
flutter test
```
*Current test status: 54/54 tests passing (100% code coverage across core flows).*

Run static analysis:
```bash
dart analyze
```
*Analysis status: 0 errors, 0 warnings.*

---

## 📄 License
This project is licensed under the MIT License.
