# Reflection Answers — [trapped] M-Commerce System

**Related Manual:** HOA07 — Reflection

---

## Reflection Question 1: What was the most challenging part of developing the system?

**Answer:**
The most challenging part was coordinating the Admin and Customer sides while
keeping the data layer consistent — especially the realtime synchronization and
the simulated payment status flow (`PAID (SIM)`, `FAIL-DEMO-...`, `CANCEL-DEMO-...`).
Coupled with the unsafe Firebase map parsing, this required careful root-cause
debugging before the final stable build.

## Reflection Question 2: What did you learn from the debugging process?

**Answer:**
We learned to validate assumptions about Firebase data shapes and to restrict
provider usage (`context.watch`) to widget build methods. The debugging journey
strengthened our ability to isolate widget-level crashes from backend data issues.

## Reflection Question 3: How did you ensure the admin could manage the system safely?

**Answer:**
Admin access is gated through Firebase Auth UID comparison against
`settings/adminUid` in the Realtime Database, with input sanitization and admin
role enforcement in the database rules.

## Reflection Question 4: What would you improve with more time?

**Answer:**
Integrate a real payment gateway, enable Firebase Storage uploads for product
images on a paid plan, and add richer analytics/reports.
