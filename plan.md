# Plan — Mock Checkout + Delivery Tracking

## Goal

Two outcomes, working identically from **both the web app and the iOS app** against the same Spring Boot backend (`BE`):

1. **Checkout is "mocked":** pressing *Checkout* always succeeds. It registers a `Deal` and creates a `Delivery` that immediately shows up for delivery-type (`DLV`) accounts to pick up. No more error on checkout.
2. **Tracking works once a delivery account processes a package:** when a `DLV` account accepts a package and advances its stage (Accepted → In Delivery → Arrived), the customer's order-tracking view reflects the live stage and, where available, the driver's location.

---

## Current behavior & root causes (why checkout errors today)

### Checkout

- `DealServiceImpl.checkout()` creates the `Deal` (status `PENDING_APPROVAL`) and, for any method other than `SELF_PICKUP`, creates a `Delivery` (`PENDING_ASSIGNMENT`).
- For **`IMMEDIATE`** it then calls `deliveryService.autoAssignNearest(...)`.
- `autoAssignNearest` only considers accounts where lat/lng is non-null (`findByLatitudeIsNotNullAndLongitudeIsNotNull`). **The only seeded delivery account (`dlv@builtin.com`, `DataInitializer`) has no lat/lng**, so the candidate list is empty and it **throws `IllegalStateException("No drivers are currently available…")`**.
- Both clients surface this as a checkout failure:
  - webApp `CartController.checkout` catches and shows *"No drivers available…"* / *"Could not place your order."*
  - iOS `CartViewModel.checkout` maps it to `APIError.noDriversAvailable`.
- Net effect: **IMMEDIATE checkout always fails**; this is the error the user sees. (STANDARD/FAST create a pending delivery and should succeed, but the requirement is that checkout never errors and the deal is always visible to DLV accounts.)

### Tracking / processing a package

- **iOS stage update uses the wrong HTTP verb.** `DeliveryDashboardViewModel.updateStage` calls `.updateDeliveryStage` with `method: .post`, but the backend maps `PATCH /api/deliveries/{id}/stage` (`@PatchMapping`). → **405**, so an iOS DLV account cannot advance a package's stage.
- **iOS driver-location broadcast hits a non-existent endpoint.** iOS `Endpoint.updateDriverLocation` → `POST /deliveries/location`. The **BE `DeliveryController` has no `/location` mapping** (only the webApp has its own `/deliveries/location`, which iOS does not use). → driver GPS never reaches the backend, so the tracking map can't move.
- Driver location for tracking is read from `DeliveryAccount.latitude/longitude` via `DeliveryResponseDto` (`driverLatitude/driverLongitude`); it's only populated if the driver's location is updated through `PATCH /api/delivery-accounts/{id}/location`.

---

## Requirements

### R1 — Mock checkout (never errors; deal registered and visible to DLV accounts)

- **R1.1** Checkout must always return success and persist a `Deal` for every shipping method (`SELF_PICKUP`, `STANDARD`, `FAST`, `IMMEDIATE`).
- **R1.2** For every non-`SELF_PICKUP` deal, a `Delivery` is created in `PENDING_ASSIGNMENT` so it appears in the DLV dashboard's "Available / Pending" list (`GET /api/deliveries/pending`).
- **R1.3** `IMMEDIATE` must no longer hard-fail when no driver has a location. Mock behavior: if auto-assign finds no eligible driver, **fall back to leaving the delivery `PENDING_ASSIGNMENT`** (still visible for manual pickup) instead of throwing. (Seeding the default account with a location, below, makes the happy path also work.)
- **R1.4** Seed the default delivery account (`dlv@builtin.com`) with a default lat/lng so auto-assign has at least one candidate.
- **R1.5** Checkout response deserializes cleanly on both clients (no lazy-load / serialization error on the returned `Deal`).
- **R1.6** Verify parity: the same flow succeeds from the iOS `CheckoutSheet` and the webApp cart.

### R2 — Tracking available when a DLV account processes a package

- **R2.1** A DLV account can **accept** a pending package (already works: `POST /accept`), moving deal → `DELIVERY` and delivery → `ACCEPTED`.
- **R2.2** A DLV account can **advance the stage** (`ACCEPTED → IN_DELIVERY → ARRIVED`) from **both** clients. Fix the iOS verb mismatch so the stage update uses `PATCH` (matching the backend).
- **R2.3** Order tracking (`GET /api/deliveries/deal/{dealId}`) reflects the current stage in near-real-time on both clients (iOS polls every 10s; web `order-tracking` page).
- **R2.4** Driver location updates reach the backend so the tracking map moves: add a backend driver-location endpoint that iOS's `updateDriverLocation` can hit (or repoint iOS to the existing `PATCH /api/delivery-accounts/{id}/location`), and confirm `driverLatitude/driverLongitude` flow into `DeliveryResponseDto`.
- **R2.5** When stage reaches `ARRIVED`, deal → `COMPLETE` and tracking shows the completed/arrived state (already wired in `updateStage`; verify end-to-end).

---

## Proposed tasks (we'll do these one by one, in order)

1. **T1 — Backend: make `IMMEDIATE` checkout non-fatal (R1.3).** In `DeliveryServiceImpl.autoAssignNearest`, return gracefully (leave `PENDING_ASSIGNMENT`) when no candidate is found instead of throwing; have `checkout` tolerate that. Decide whether to keep the iOS/web "no drivers" messaging or remove it.
2. **T2 — Backend: seed default driver location (R1.4).** Give `dlv@builtin.com` a default lat/lng in `DataInitializer`.
3. **T3 — Backend: verify checkout response serialization (R1.5).** Confirm the returned `Deal` carries no lazy collections that break JSON; add a lightweight response DTO if needed.
4. **T4 — Verify checkout end-to-end (R1.1, R1.2, R1.6).** Run BE + place orders for each method from web and iOS; confirm deals appear in `GET /api/deliveries/pending` and the DLV dashboards.
5. **T5 — iOS: fix stage-update verb (R2.2).** Change `DeliveryDashboardViewModel.updateStage` to use `PATCH` (and audit `eta` if it has the same issue).
6. **T6 — Driver location endpoint (R2.4).** Add `POST /api/deliveries/location` on the BE (or repoint iOS to `PATCH /api/delivery-accounts/{id}/location`), wiring driver lat/lng into the account.
7. **T7 — Verify tracking end-to-end (R2.1, R2.3, R2.5).** Accept a package as DLV, advance stages, confirm the customer tracking view updates on both clients through to `ARRIVED`/`COMPLETE`.

---

## R3 — Purchases / order history per user (NEW)

A logged-in user can see **all their orders** in a **Purchases** tab on both clients, each row showing the order and its **status** (Pending / Processing / Out for delivery / Delivered / Canceled, derived from `DealStatus`).

- **R3.1 Backend:** expose `GET /api/deals/user/{userId}` returning that user's deals (repo method `findByUserId` already exists).
- **R3.2 Status mapping:** `PENDING_APPROVAL → Pending`, `PROCESSING → Processing`, `DELIVERY → Out for delivery`, `COMPLETE → Delivered`, `CANCELED → Canceled`.
- **R3.3 iOS:** new **Purchases** tab in `CustomerTabView` listing the current user's deals (id, date, total, shipping method, status badge), newest first, with pull-to-refresh.
- **R3.4 webApp:** new **Purchases** page + nav link, listing the session user's deals with status badges.
- **R3.5** Checkout already attaches the logged-in user (guest orders, `userId<=0`, simply won't appear in a user's purchases — expected).

### Tasks for R3 (one by one)

8. **T8 — Backend deals-by-user endpoint (R3.1).** `DealService.getDealsByUser` + impl (`findByUserId`) + `GET /api/deals/user/{userId}`.
9. **T9 — iOS Purchases tab (R3.3).** `Endpoint.userDeals`, `PurchasesViewModel`, `PurchasesView`, status badge, add tab.
10. **T10 — webApp Purchases page (R3.4).** `DealClient.getDealsByUser`, controller route `/purchases`, `purchases.ftlh`, nav link.

## R4 — Real user identity for mock logins (prereq for R3) (NEW)

Both clients mock-login with customer `id: 0`, and no CUSTOMER user exists in the DB, so customer orders are saved as **guest** and never appear in Purchases. To make R3 work end-to-end:

- **R4.1** Seed a `CUSTOMER` user (`user@builtin.com`) in `DataInitializer`.
- **R4.2** Add `GET /api/users/by-email/{email}` to the BE.
- **R4.3** webApp `AuthController` resolves the logged-in user's real id by email (via `UserClient`) and stores it in the session.
- **R4.4** iOS `AuthViewModel` resolves the real id by email and stores it on the `UserDto`.

### Task

11. **T11 — Real user id on login (R4).** Seed customer user, add by-email endpoint, resolve id in both login flows.

## Decisions (resolved)

- **D1 (T1):** When `IMMEDIATE` finds no driver, **leave the delivery `PENDING_ASSIGNMENT`** for manual pickup. Checkout never errors.
- **D2 (T6):** **Add the BE `POST /api/deliveries/location` endpoint**; iOS stays unchanged.
- **D3:** **BE (builtin) source may be edited freely** — it is separate from the org-restricted PoSA/siteseal_src repo.
</content>
</invoke>
