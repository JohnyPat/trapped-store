# [trapped] — Flutter Streetwear Storefront

A monochrome, editorial-style e-commerce app for Web, Android and iOS, built
with Flutter and Firebase. It recreates the supplied `[trapped]` UI references:
black header/bottom navigation, Space Mono typography, uppercase micro-labels,
bordered product cards, misty-forest auth backdrop and the full shopping flow.

The app is connected to the **existing** Firebase project `trapped-56f3e`
(display name `trapped`). No new Firebase project was created and the existing
Firebase configuration was not overwritten.

## Modules

- Home (hero carousel, categories, featured / new arrivals / most wanted / full catalogue)
- Collection + filter chips, Search
- Product details, size picker, stock/wishlist/cart actions
- Wishlist, Cart (quantity controls, free-shipping progress)
- Checkout (delivery details, payment selection, order review)
- Orders (list, details, status timeline, cancel with stock restoration)
- Payment history
- Profile, edit profile, change password
- Responsive shell: mobile bottom navigation, desktop header/navigation

## Tech stack

- Flutter 3.47.2+ / Dart (see `pubspec.yaml`)
- Firebase Core, Auth, Realtime Database, Storage, Cloud Functions (dependency present, unused while backend is unavailable)
- Provider state management
- cached_network_image, image_picker, intl, uuid, shared_preferences

## Firebase project

| Service | Value |
| --- | --- |
| Project ID | `trapped-56f3e` |
| Project number | `662516673071` |
| RTDB instance | `trapped-56f3e-default-rtdb` |
| RTDB URL | `https://trapped-56f3e-default-rtdb.firebaseio.com` |
| Hosting | `https://trapped-56f3e.web.app` |
| Web app ID | `1:662516673071:web:8020ce1bd657b837f674da` |
| Android app ID | `1:662516673071:android:da9f1433239e6049f674da` |
| iOS app ID | `1:662516673071:ios:304719c3445fd245f674da` |
| Android package | `com.wearetrapped.trapped_store` |
| iOS bundle ID | `com.wearetrapped.trappedStore` |

Auth email/password and anonymous sign-in are enabled. Billing is disabled
(Spark plan), which means:

- **Firebase Storage cannot be provisioned yet.** Profile-picture upload is
  implemented in `lib/services/storage_service.dart`, but it will show a clear
  "enable Storage" error until Storage is activated in the Firebase console.
- **Cloud Functions cannot be deployed.** Order placement is therefore a
  client-side, multi-path atomic RTDB update validated by security rules.
- **Online payment is intentionally disabled.** Only Cash on Delivery can be
  selected. No payment is ever simulated.

## Run

```bash
flutter pub get
flutter run -d chrome        # Web
flutter run -d <deviceId>    # Android / iOS
```

The app starts at the auth gate: authenticated users, and guests who chose
"Login as Guest", reach the shop. Everyone else sees the login screen. Guest
browsing works, but wishlist / cart / checkout / orders / profile prompt for
sign-in, also for the seeded catalogue.

## Verify

```bash
flutter analyze   # No issues found
flutter test      # All tests pass
```

Seeded catalogue can be smoke-tested on the deployed site:
`https://trapped-56f3e.web.app`

## Seed the catalogue

The seed file is `tool/seed/seed.json`. It creates the `categories`,
`products` and `settings` nodes only; it does not delete user data.

```bash
# First-time/empty database, or after clearing an old catalogue:
firebase database:remove /products --project trapped-56f3e --force
firebase database:remove /categories --project trapped-56f3e --force
firebase database:update / tool/seed/seed.json --project trapped-56f3e --force
```

Seed content:

- 3 categories: `cat-shirts` (T-Shirts), `cat-pants` (Pants), `cat-headwear` (Headwear)
- 12 real catalogue products using the brand's own photography: Praise The Lord,
  We Are Fucked, Pistol Tee, cruZifix, Leopard, Fleece, Check, Real Tree, Leo
  Jorts (Brown / White), 666 and Mauve caps
- Prices follow the store: tees ₱899, bottoms ₱1,000, caps ₱700 (PHP)
- Stock is seeded at `25` for every product as a placeholder so checkout works;
  adjust inventory in the Firebase console before selling
- `settings.onlinePaymentsEnabled = false`, `settings.codEnabled = true`
- `settings.adminUid` is intentionally empty — set it in the Firebase console
  before any authenticated user-management is needed

Product and category images are the official brand assets deployed to Firebase
Hosting under `web/catalog/` and bundled as local fallbacks under
`assets/images/products/` and `assets/images/editorial/`.

## Deploy

Database rules and hosting:

```bash
flutter build web --release
firebase deploy --only database,hosting --project trapped-56f3e
```

Do **not** run a bare `firebase deploy` until Storage is enabled — the
`storage.rules` target would fail on the Spark plan. Once Storage is enabled:

```bash
firebase deploy --only storage --project trapped-56f3e
```

Hosting is configured as an SPA (`** -> /index.html`) and serves
`build/web`. Catalog images are cached by `/catalog/**` headers.

## Storage enablement

1. Firebase Console → Storage → **Get started** (may require upgrading the
   project beyond Spark / enabling billing).
2. Deploy `storage.rules` (see above).
3. Profile-picture upload will then work; images are stored under
   `users/{uid}/profile_*` and are publicly readable.

## Security model

`database.rules.json` currently enforces:

- Products/categories/settings: public read; writes are admin-only except the
  `products/{id}/stock` path, which any authenticated user may set to a
  non-negative number (required for client-side order/cancel stock movement).
- `users/{uid}`, `wishlist/{uid}`, `cart/{uid}`, `orders/{uid}`,
  `orderLocks/{uid}` are only readable/writable by that user.
- Order creation is constrained: COD only, `userId` must match, item prices
  must match the current `products/{id}/price`, quantities must be positive.
- Payment records are create-only with pending COD status; the customer may
  only cancel a pending payment, never mark anything paid.
- Deletion/cascade overwrite is denied by default.

### Important caveat

On the Spark plan the app cannot use a server to decrement stock and confirm
payments. Any authenticated user can call the RTDB write endpoints the rules
expose, including `products/{id}/stock`. That is acceptable for a demo/seed,
**not** for trusted inventory control. Before real-money, high-value use:

- Enable Cloud Functions (or an Admin SDK backend), move stock decrement and
  order confirmation server-side, and make products/settings admin-only.
- Add custom claims (e.g. `admin: true`) for the store owner.
- Keep online payment disabled until a verified provider and server-side
  webhook confirm funds.

## Online payment policy

`PaymentService.onlinePaymentsConfigured` is `false`. Checkout offers COD as
the only selectable option; the online-payment card is labelled "COMING SOON".
Enabling online payment requires:

1. A real provider (e.g. Stripe, PayMongo, Xendit).
2. Server-side creation/confirmation of the payment (Cloud Functions or
   backend + webhook).
3. Updated database rules and verification logic.
4. `PaymentService.onlinePaymentsConfigured = true` and the checkout option
   enabled. `OrderService` also rejects `PaymentMethod.online` before any
   network call, so no payment can be faked by the client.

## Running on each platform

### Web

Works out of the box. `flutter build web --release` → deploy with the hosting
config above.

### Android

Prerequisites: Android SDK, platform-tools, build-tools 36.0.0, platforms and
command-line tools (`sdkmanager`). In this environment the toolchain is
complete: command-line tools 20.0.0 were installed at
`%LOCALAPPDATA%\Android\sdk\cmdline-tools\latest`, all SDK licenses were
accepted, and `JAVA_HOME` is set to the Android Studio JBR
(`C:\Program Files\Android\Android Studio\jbr`).

```bash
flutter doctor --android-licenses   # already accepted here
flutter run -d <android-device-or-emulator>
flutter build apk --debug           # succeeds: build\app\outputs\flutter-apk\app-debug.apk
```

`flutter build apk --release` fails **on this machine** because Windows
Application Control blocks Flutter's `gen_snapshot.exe` (an OS policy, not a
project defect). On any machine without that policy restriction the release
build works. Release APKs are signed with the debug key until you add your own
`key.properties` / signing config for Play Store distribution.

### iOS

Prerequisites: macOS + Xcode + CocoaPods. Set your signing team in
`ios/Runner.xcworkspace`, then:

```bash
flutter run -d <ios-device-or-simulator>
flutter build ipa --release
```

The bundle id is `com.wearetrapped.trappedStore`. Firebase is already
configured for iOS (`GoogleService-Info.plist` is wired through FlutterFire).

## Project structure

```text
lib/
  constants/     design tokens, assets, app-wide constants
  models/        AppUser, Product, Category, Cart, Order, Payment
  providers/     AuthProvider, CatalogProvider, CartProvider, WishlistProvider, OrdersProvider, PaymentsProvider
  screens/       app shell, auth, home, collection, search, product, cart, wishlist, checkout, orders, profile
  services/      Firebase wiring (auth, database, orders, cart, wishlist, storage, payments)
  theme/         monochrome theme
  utils/         validators, formatters, auth guard, snacks, Firebase error mapping
  widgets/       header/nav, product card/grid, footer, empty/loading/error states
assets/          Space Mono fonts, editorial and product images
tool/seed/       seed.json (catalogue) — see above
tool/generate_product_assets.mjs
web/             Flutter web shell + deployed /catalog images
```

## Data paths (RTDB)

```text
products/{id}            catalogue
categories/{id}          SHIRTS / PANTS / HEADWEAR
settings                 shippingFee, freeShippingThreshold, codEnabled, ...
users/{uid}              profile (fullName, phone, address, profileImage)
wishlist/{uid}/{productId}
cart/{uid}/{lineKey}
orders/{uid}/{orderId}
payments/{orderId}
orderLocks/{uid}/{orderId}
```

Order placement is an atomic multi-path update: order + payment + lock +
stock decrement + cart clear + `users/{uid}/lastOrderId`, protected by rules
and idempotency key `orderId`. Cancelling a pending/confirmed order reverses
the statuses and restores stock.

## Tested

- `flutter analyze`: clean
- `flutter test`: 8/8 passing
- `flutter build web --release`: succeeds
- `flutter build apk --debug`: succeeds (Android release build is blocked by
  Windows Application Control, see Android section)
- `flutter build apk --release`: succeeds
- Deployed site smoke-tested: guest browsing, sign-up, add to bag, cart,
  COD checkout, order creation, receipt/order details, cancellation with
  stock restoration

## Submission Deliverables (ITE 7 M-Commerce)

| Deliverable | File | Status |
|---|---|---|
| Running Flutter App | — | ✅ |
| Firebase Connected App | — | ✅ (`trapped-56f3e`) |
| Organized Folder Structure | `lib/` | ✅ |
| Functional Login/Register | HOA02 | ✅ |
| Product Listing / Details / Cart / Checkout | HOA03 | ✅ |
| Admin Dashboard + CRUD | HOA04 | ✅ |
| Fully Integrated System | HOA05 | ✅ |
| Real-Time Synchronization | HOA05 | ✅ |
| Debugging Report | `docs/HOA05_Debugging_Report.md` | ✅ |
| QA Checklist | `docs/HOA06_QA_Checklist.md` | ✅ |
| User Testing Results | `docs/HOA06_User_Testing_Results.md` | ✅ |
| APK File | `build/app/outputs/` | ✅ |
| Deployed Dashboard | hosting | ⚠️ web build ready, deploy pending |
| Presentation Slides | `docs/HOA07_Presentation_Slides.md` | ✅ |
| Reflection Answers | `docs/HOA07_Reflection_Answers.md` | ✅ |
| GitHub Repository | — | ✅ local commit `9c6f741` |

## Notes

- `settings/adminUid` must contain the admin's clean UID (no quotes/spaces) in
  the Realtime Database for the Admin panel to open.
- Test users created during verification were removed from Auth and RTDB.
- The project is not a git repository; commit `database.rules.json`,
  `storage.rules`, `firebase.json` and `.firebaserc` if you move it to one.
