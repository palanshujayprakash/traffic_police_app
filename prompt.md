You are my senior full-stack mobile engineer. We are building "Traffic Police Assistant", a Flutter mobile app for traffic inspectors in India.

SKILLS TO USE (mandatory):
- Use the "agent-skills" skill for planning, coding standards, testing and review at every step.
- Use the "ponytail" skill whenever you build or change UI, so every screen looks professional and consistent.
- Use the "cavemem" skill to store project decisions, progress and context, and read it at the start of every session so you never lose context.
If any of these skills is not available, tell me first instead of skipping it.

PROJECT CONTEXT:
- UI design exports from Stitch are in /design (screenshots + HTML). Match them exactly: navy #0B2A5B primary, saffron #F59E0B accent, Inter font, rounded cards, green/amber/red status badges, bottom navigation (Home, Search, Challan, History, Profile).
- Stack: Flutter + Supabase. Use dummy vehicle data for now (bike, car, truck, bus, tractor) with RC, insurance, PUC, fitness, permit and pending challans. Real VAHAN/e-Challan API comes later behind a service interface so it can be swapped easily.

FEATURES:
1. Login with mobile number + email + OTP. Only admin-registered inspectors (whitelist) can log in. OTP expires in 5 minutes, lock after 3 wrong attempts. Quick re-login with PIN/fingerprint.
2. Vehicle search by registration number, chassis number, engine number.
3. Vehicle details with green/amber/red expiry badges and a red alert banner for stolen/blacklisted vehicles.
4. Driver license check.
5. Challan check and issue (violation list, auto fine, photo, GPS, timestamp, inspector ID), receipt with UPI QR, share via WhatsApp/SMS.
6. Number plate scan (OCR) using Google ML Kit.
7. History, reports, profile, Hindi/English support, offline mode.
8. Admin panel (inspector management, fines, reports).

RULES:
- Clean architecture, reusable widgets, no hardcoded colors (use a theme file).
- Never put secrets or API keys in code; use environment config.
- Add an audit log for every search and challan action.
- Write simple tests for login, search and challan logic.

WORKFLOW (follow strictly):
1. First, read the /design folder and give me a short plan with phases. Wait for my "go".
2. Build ONE phase at a time: Phase 1 theme + reusable widgets, Phase 2 screens with dummy data, Phase 3 Supabase + login, Phase 4 search + challan, Phase 5 plate scan, Phase 6 offline, admin and reports.
3. After each phase: run the app, fix errors, save progress in cavemem, summarize what was done, and wait for my approval.