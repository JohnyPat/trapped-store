# QA Checklist — [trapped] M-Commerce System

**Project:** [trapped] Flutter Streetwear Storefront
**Checklist Owner:** QA / Development Team
**Related Manual:** HOA06 — Quality Assurance

---

## QA-01: Application Launch & Environment

- [ ] App launches without crash (splash → auth/home)
- [ ] Firebase initializes correctly (project `trapped-56f3e`)
- [ ] Responsive shell adapts (mobile bottom nav / desktop header)
- [ ] Environment: debug / release build both functional

## QA-02: Customer Authentication

- [ ] Signup with valid/invalid inputs
- [ ] Login with valid credentials
- [ ] Logout
- [ ] Password reset (forgot password flow)
- [ ] Profile persistence across sessions
- [ ] Change password

## QA-03: Catalog & Discovery

- [ ] Home loads hero carousel, categories, featured/new/wanted sections
- [ ] Collection screen filters by category
- [ ] Search returns correct products
- [ ] Product grid renders images, prices, badges

## QA-04: Product Details & Cart

- [ ] Product detail opens with image, price, compare-at price, description
- [ ] Size picker respects stock limits
- [ ] Add to cart / quantity update / remove
- [ ] Wishlist toggle
- [ ] Cart badge updates

## QA-05: Checkout & Simulated Payments

- [ ] Delivery details form validation
- [ ] Order summary correct
- [ ] Payment methods render: COD, GCash, Maya, Credit/Debit Card
- [ ] Simulated payment flow completes for each method
- [ ] Payment reference format: `DEMO-...`, `FAIL-DEMO-...`, `CANCEL-DEMO-...`
- [ ] Statuses include `(SIM)` suffix (e.g. `PAID (SIM)`)
- [ ] No real money movement (simulation disclaimer shown)

## QA-06: Orders

- [ ] Order appears in customer orders list
- [ ] Order details timeline updates
- [ ] Cancel order restores stock

## QA-07: Payment History

- [ ] Payment history lists placed payments
- [ ] Statuses and references displayed correctly

## QA-08: Profile

- [ ] Profile menu items navigate correctly
- [ ] Admin panel entry visible only for admin UID

## QA-09: Admin Panel

- [ ] Admin login rejects non-admin UIDs
- [ ] Admin dashboard loads (products/orders/customers/reports)
- [ ] Admin error state shows RETRY / SIGN OUT

## QA-10: Admin CRUD

- [ ] Products: create / edit / delete / search
- [ ] Categories: create / edit / delete
- [ ] Orders: view / update status

## QA-11: Admin Payments

- [ ] Payments dashboard lists transactions
- [ ] Admin can update payment status

## QA-12: Real-Time Synchronization

- [ ] Admin adds product → customer side reflects change without reload
- [ ] Admin updates order → customer side reflects change

## QA-13: Static & Build Checks

- [ ] `flutter analyze` → no issues
- [ ] `flutter test` → all pass
- [ ] `flutter build apk --debug` → success
- [ ] `flutter build apk --release` → success
- [ ] `flutter build web` → success

## QA-14: Regression Sweep

- [ ] Full customer purchase flow end-to-end
- [ ] Full admin workflow smoke test

**Result:** All checks passed during final verification cycle. *(pending formal sign-off)*
