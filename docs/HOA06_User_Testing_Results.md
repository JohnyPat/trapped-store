# User Testing Results — [trapped] M-Commerce System

**Project:** [trapped] Flutter Streetwear Storefront
**Related Manual:** HOA06 — User Testing

---

## 1. Test Environment

- Device / platform: Android emulator / physical device (demo build `app-debug.apk`)
- Firebase project: `trapped-56f3e`
- Accounts used:
  - Customer: `jp@gmail.com`
  - Admin: `admin@gmail.com`

## 2. Test Scenarios & Results

| # | Scenario | Steps | Expected Result | Observed Result | Status |
|---|---|---|---|---|---|
| UT-01 | Customer signup | Register with valid details | Account created, logged in | ✅ Passed | PASS |
| UT-02 | Customer login | Login with valid credentials | Session persisted | ✅ Passed | PASS |
| UT-03 | Browse catalog | Home → Collection → Product | Product details load with price/stock | ✅ Passed | PASS |
| UT-04 | Add to cart & checkout | Add item, delivery info, place order | Order created, payment record written | ✅ Passed | PASS |
| UT-05 | Simulated payment (COD) | Checkout → COD → Place order | Order status `PENDING (SIM)` | ✅ Passed | PASS |
| UT-06 | Simulated payment (GCash/Maya/Card) | Checkout → selected method → simulate | Payment ref `DEMO-...`, status `PAID (SIM)` | ✅ Passed | PASS |
| UT-07 | Fail payment simulation | Trigger `FAIL-DEMO-...` path | Order/payment marked failed/rejected | ✅ Passed | PASS |
| UT-08 | Cancel payment simulation | Trigger `CANCEL-DEMO-...` path | Payment marked cancelled | ✅ Passed | PASS |
| UT-09 | Orders list & details | Open order from history | Timeline/status display | ✅ Passed | PASS |
| UT-10 | Payment history | Open profile → Payments | All transactions listed | ✅ Passed | PASS |
| UT-11 | Admin login | Login as admin | Dashboard loads | ✅ Passed | PASS |
| UT-12 | Admin add product | Add product via form | Product appears in catalog live | ✅ Passed | PASS |
| UT-13 | Admin update order status | Update order status | Customer sees new status | ✅ Passed | PASS |
| UT-14 | About page edit | Admin Site tab → edit → save | Customer sees updated content | ✅ Passed | PASS |
| UT-15 | Customer sees admin changes | Real-time sync check | No reload required | ✅ Passed | PASS |

## 3. Summary

All 15 user-representative test scenarios passed during the final acceptance
cycle. No critical defects were reported during live walkthroughs.

## 4. Feedback / Open Items

- [ ] Formal user feedback forms to be collected (HOA06 deliverable).
- [ ] Real payment gateway integration (production) — out of scope (simulation).
