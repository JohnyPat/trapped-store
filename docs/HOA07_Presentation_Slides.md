# Presentation Slides — [trapped] M-Commerce System

**Related Manual:** HOA07 — Presentation
**Slides:** 10 content slides (HOA07 Step 1)

---

## Slide 1 — Title

- **[trapped]** — Monochrome Streetwear Storefront
- M-Commerce System (Flutter + Firebase)
- Presenter / Team
- Date

## Slide 2 — Introduction & Problem

- Independent streetwear brand: `[trapped]`
- Mission: *"We Were Never Meant To Fit Inside The Boxes."*
- Problem: online store + admin dashboard + payments in one system

## Slide 3 — Objectives

- Customer side: browse, cart, checkout, orders, payments
- Admin side: dashboard, CRUD, order/payment monitoring, site content editor
- Simulated online payments (GCash / Maya / Card / COD)

## Slide 4 — Technology Stack

- Flutter 3.47 (Dart 3.13)
- Firebase: Auth, Realtime Database, Storage, Hosting
- Provider state management
- Firebase CLI (`trapped-56f3e`)

## Slide 5 — Customer Features

- Home, Collection, Search, Product Details
- Cart, Wishlist, Checkout, Orders, Payment History
- Profile

## Slide 6 — Admin Features

- Admin Dashboard (products / categories / orders / customers / reports / payments / site)
- Admin auth via `settings/adminUid`
- Live data sync via Realtime Database streams

## Slide 7 — Simulated Payments

- Methods: COD, GCash, Maya, Credit/Debit Card
- Reference prefixes: `DEMO-`, `FAIL-DEMO-`, `CANCEL-DEMO-`
- Statuses marked `(SIM)` — no real money movement

## Slide 8 — Architecture & Real-Time Sync

- Realtime Database `onValue` streams
- Admin writes → customer reads (live)
- Security rules: admin-only writes, public reads for catalog

## Slide 9 — Verification

- `flutter analyze` — clean
- `flutter test` — 8/8 passed
- Builds: web ✅, apk-debug ✅, apk-release ✅

## Slide 10 — Demo & Conclusion

- Live walkthrough: customer purchase + admin management
- Conclusion: complete M-Commerce system delivered

---

## Speaker Notes (key points)

1. Emphasize that payments are simulated for the academic demo — no real
   bank/card integration, per requirements.
2. Emphasize real-time sync via Firebase Realtime Database.
3. Mention the admin UID security gate.
