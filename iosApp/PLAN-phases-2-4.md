# iOS App — Plan for Phases 2 → 4

> Scope: bring the iOS app to feature parity with the webApp customer flow.
> Phases per `iosApp/README.md` build-phase checklist.
> Reference: `BE/src/resources/mantainance1.md` for the recent web/BE fixes that iOS needs to mirror.

## Context

The README marks "Phase 1 complete", but a substantial amount of phase 2 and phase 3 code already exists on disk:

- **Phase 2 (Auth):** `LoginView`, `AuthViewModel`, `UserSession` — implemented.
- **Phase 3 (Customer Flow):** `HomeView`, `ProductsView`, `ProductDetailView`, `ProviderProductsView`, `CartView`, `CheckoutSheet`, `OrderTrackingView`, `SearchView`, plus their view-models and shared components — implemented.
- **Phase 4 (AI Tools — Calculator & Agent):** **nothing on disk yet.** DTOs (`CalculatorDto`, `AgentDto`) and the network layer are ready, but no views, view-models, or tab routes.

So the real work is: (a) audit & gap-fill phase 2/3 to match the recent webApp/BE maintenance changes, then (b) build phase 4 from scratch. Phases 5–8 stay out of scope for this round.

---

## Gap audit (what we *would* have caught in a parity review)

These are real gaps between the iOS app today and the webApp after `mantainance1.md` work:

1. **Shipping-method picker in cart.** Web `cart.ftlh` exposes a 4-way picker (SELF_PICKUP / IMMEDIATE / FAST / STANDARD) that re-prices each item via `cartItem.prices`. iOS `CartView.swift` groups by `shippingTime` and always shows the base `item.price`, never the per-method price.
2. **Tracking fallback when coordinates are missing.** Web shows a "Driver location not yet available" panel when `stage == IN_DELIVERY` but `driverLatitude/longitude` are null. iOS `OrderTrackingView.swift:23` simply hides the map (`if delivery.driverLatitude != nil`), which silently leaves the user wondering.
3. **Customer-friendly stage labels.** Web tracking page uses "Order Received / Accepted by Courier / Out for Delivery / Delivered". iOS uses raw `DeliveryStage.displayLabel`. Worth aligning so the language is consistent across surfaces.
4. **Auto-refresh.** Web auto-refreshes the tracking page every 30 s. iOS has `OrderTrackingViewModel.stopPolling()` on disappear — verify a `startPolling()` is wired on appear; if it just one-shots `track(dealId:)`, add a 30 s refresher.
5. **Calculator + Agent surfaces.** Don't exist. Customer tab bar only has Home / Products / Cart / Track / Profile.

---

## Phase 2 — Authentication (audit-only)

**Likely no code changes.** Tasks:

- T2.1 — Run the app, sign in as a customer (`omar@customer.com` / whatever seed creds the BE uses), confirm the bearer token round-trips through `APIClient.setToken(...)` and persists across relaunch via `UserSession`. Check logout clears `UserSession` and resets `AppState`.
- T2.2 — Confirm the role-based router in `App/RootView.swift:6-21` lands customers on `CustomerTabView`, providers on the placeholder `ProviderTabView` (phase-5 scope, fine to leave), drivers on placeholder `DeliveryTabView`, super-admin on placeholder `AdminTabView`.
- T2.3 — If anything is broken, fix; otherwise mark phase 2 done in the README.

Files to look at if there is a fix: `Views/Login/LoginView.swift`, `ViewModels/AuthViewModel.swift`, `Services/UserSession.swift`, `App/AppState.swift:14-27`.

## Phase 3 — Customer Flow (gap-fill)

### T3.1 — Cart: per-method pricing picker
- `Views/Cart/CartView.swift` — replace the static "Ships in {time}" grouping with:
  - A `ShippingMethodPicker` segmented control above the list (4 options).
  - When user picks a method, each item row shows `item.prices.first(where: { $0.shippingMethod == picked })?.amount` instead of `item.price`. Fall back to base price when no matching `ItemPrice`.
  - Cart total recomputes from the per-method prices.
  - Selected method is what `CheckoutSheet` submits, removing whatever default it has now.
- `App/AppState.swift` — add `@Published var selectedShippingMethod: ShippingMethod = .standard` so the picker survives a tab switch.
- `Models/CartDto.swift` — likely already has `prices: [ItemPriceDto]` per `AppState.addToCart` line 43. Add a small helper `func effectivePrice(for: ShippingMethod) -> Decimal` mirroring `BE/.../util/Pricing.java::effectivePrice` (M3) so the UI doesn't reimplement the pricing rule.

### T3.2 — Order tracking: fallback panel & visible polling
- `Views/Tracking/OrderTrackingView.swift:23` — when `delivery.stage == .inDelivery` and `driverLatitude == nil`, render a yellow/secondary panel saying "Driver location not yet available" (i18n later). Today it just hides the section.
- Make `OrderTrackingViewModel` poll `/deliveries/{id}` every 30 s while the view is on-screen (cancel on disappear). The polling loop in `OrderTrackingViewModel.startPolling()` / `stopPolling()` may already exist — confirm both halves are wired.
- Add a footer "Updated {hh:mm}" so the user knows the refresh is live (web `tracking.last_updated`).

### T3.3 — Stage label parity
- `Models/DeliveryDto.swift` (or wherever `DeliveryStage.displayLabel` lives): add a second computed label `customerLabel` matching `tracking.stage.*` keys in `webApp/.../messages.properties`. Use it in `OrderTrackingView`; keep the existing label for `DeliveryDashboard` when that's built in phase 6.

### T3.4 — Smoke-test the customer flow end to end
Start BE (`localhost:8080`) and the iOS sim against `http://<mac-ip>:8080/api`, then: log in → home → products → add to cart → flip shipping method → checkout → land on tracking → see stage + (if available) map.

## Phase 4 — AI Tools (build from scratch)

### T4.1 — Calculator
New files:
- `ViewModels/CalculatorViewModel.swift` — wraps `APIClient.request(Endpoint.calculator, .post, body: CalculatorRequest, …) -> CalculatorResponse`. Holds form state (structureType, length/width/height/thickness) and the response.
- `Views/Calculator/CalculatorView.swift` — form (segmented picker for ROOF_SLAB vs WALL; numeric fields for the relevant dimensions; "Calculate" button) → results list (one section per `MaterialLine` with the matched items, lowest-price highlighted). Each matched item gets an "Add to Cart" button calling `appState.addToCart(...)`.
- Endpoint should already exist in `Network/Endpoint.swift` — verify.

### T4.2 — AI Agent
New files:
- `ViewModels/AgentViewModel.swift` — wraps `Endpoint.agent` with `AgentRequest { message }` body.
- `Views/Agent/AgentView.swift` — text editor for the project description, "Calculate" button, results identical in shape to the Calculator output (re-use a shared `MatchedItemRow` view).

### T4.3 — Tabs
- `App/RootView.swift:30-54` — add two more tabs to `CustomerTabView`:
  - Tab "Calculator" → `CalculatorView` (icon `function`)
  - Tab "AI Agent" → `AgentView` (icon `sparkles`)
  Either replace one of the existing tabs (Home or Search) or use a `More` overflow; six tabs is the SwiftUI cap.

### T4.4 — Shared MatchedItem row
- `Views/Shared/MatchedItemRow.swift` — used by both Calculator and Agent results. Renders item name, provider, lowest-price badge, price, "Add to Cart" button. Avoids duplicating the row inside both screens.

---

## What we are NOT doing in this round

- **Localization to he/ar/ru/zh.** All iOS strings stay English for now; that's the README's Phase 8. (Webapp does this in M4 — iOS parity is a separate later task.)
- **Provider tab (phase 5).** `ProviderTabView` stays as placeholder `Text(…)` views.
- **Delivery tab (phase 6) and Admin tab (phase 7).** Same.
- **Driver GPS broadcast (M5 driver-side).** Customer-facing map fallback is in scope (T3.2); driver-side broadcasting is phase 6.

## Suggested execution order

1. T2 (audit) — likely zero code, single sim run.
2. T3.1 (cart picker) — highest-impact gap because it's the M1 web fix coming home to iOS.
3. T3.2 + T3.3 (tracking fallback + stage labels) — small UI tweaks.
4. T4.1 → T4.2 → T4.3 → T4.4 (AI tools, in that order — Calculator first because the request schema is simpler).
5. T3.4 (end-to-end smoke) — last, once everything's wired.

## How to verify

After all tasks:
- Run BE (already up), regenerate the Xcode project (`cd iosApp && xcodegen generate`), launch the iOS sim.
- As a customer: log in, add an item to cart from products, flip the shipping method, confirm the line prices change, checkout, watch the tracking screen update.
- Open Calculator: enter 5×4×0.2 roof slab, confirm the response renders 3 materials with matched items, add one to cart.
- Open AI Agent: type "I want a 4m oak wall closet, 60cm deep, 2m high", confirm it returns wood/screws/glue/sandpaper with matched items.
