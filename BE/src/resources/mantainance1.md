# Maintenance Plan 1 — Webapp + Backend Bug Fixes

> Scope: `webApp/` (Spring Boot + Freemarker) and `BE/` (Spring Boot REST). Mobile/iOS/Android **out of scope**.

## Context

After the recent feature commits (Task 5 Delivery Page, Task 6 GPS Parcel Tracking, Task 8 Item & Provider Location Management, Task 9 Multi-Provider Pricing per Item), several user-facing flows are broken or partially wired. The investigation found that:

- The new `CartItemDto.prices` field added in Task 9 is wired correctly in the Cart flow but `null` is passed in the Calculator and Agent flows (the uncommitted edits in `AgentWebController` and `CalculatorWebController`). Downstream code that depends on per-shipping-method pricing therefore silently sees no pricing options when items arrive via those flows.
- Provider "add product" form predates the multi-pricing model and has no fields for per-shipping-method prices — items are created without an `ItemPrice` row, and the create path has not been updated to initialize one.
- The "package selection" algorithms in `CalculatorServiceImpl` and `AgentServiceImpl` still sort by `Item.getPrice()` (the legacy base price) and ignore `Item.getPrices()` entirely.
- `messages_*.properties` files all have ~96 keys, but several templates added in recent tasks (delivery dashboard, delivery detail, order tracking, nav menu) hardcode English strings instead of looking up message keys — so switching language only translates the old screens.
- The GPS tracking uses **Leaflet / OpenStreetMap**, not Google Maps as the user phrased it. The map only renders when `delivery.stage == "IN_DELIVERY"` AND `driverLatitude` AND `driverLongitude` are all non-null, with no fallback UI when any of those are missing, and the driver-side `navigator.geolocation.watchPosition` broadcast is only started when `inDeliveryCount > 0`.

Goal: turn these into discrete, individually-shippable tasks. This document is the maintenance backlog — implementation happens in follow-up sessions, one task at a time.

---

## Tasks

### Task M1 — Restore multi-pricing in Calculator & Agent → Cart handoff
**Why first:** smallest, unblocks correct testing of M3 and M5; the uncommitted `null` lines are an active regression.

- Files:
  - `webApp/src/main/java/com/builtin/webapp/controller/AgentWebController.java:60-70`
  - `webApp/src/main/java/com/builtin/webapp/controller/CalculatorWebController.java:65-75`
  - Reference: `CartController.java:64-73` already does this correctly — passes `item.getPrices()` as the 8th arg.
- Change: replace the `null` 8th argument in the `new CartItemDto(...)` calls with `item.getPrices()` (which is `List<ItemPriceDto>` on `ItemDto`).
- Verify:
  - Add an item to cart via the Calculator page and via the Agent page.
  - Open `/cart`, change the shipping-method radio, confirm per-item prices update (the JS in `cart.ftlh:199-226` builds an `itemPriceMap` from `cartItem.prices`).

### Task M2 — Fix "Add new product as provider" (create flow)
**Symptom:** provider clicks "Add Item", submits the form, request fails or item is created with no usable pricing.

- Files:
  - `webApp/src/main/resources/templates/add-item.ftlh` (no multi-pricing fields today)
  - `webApp/src/main/java/com/builtin/webapp/controller/ItemFormController.java:64-93`
  - `webApp/src/main/java/com/builtin/webapp/dto/CreateItemRequest.java` (no `prices` field)
  - `webApp/src/main/java/com/builtin/webapp/client/ItemClient.java:60-68`
  - `BE/src/main/java/com/builtin/controller/ItemController.java:36-39`
  - `BE/src/main/java/com/builtin/service/impl/ItemServiceImpl.java:45-59` and `setItemPrices` around `:104`
- Subtasks:
  1. Reproduce locally with the BE running; capture the actual error (stack trace vs. validation message vs. silent 200 with empty pricing). The leading hypothesis is an NPE on `item.getPrices().clear()` when the incoming entity has a null `prices` collection, but confirm before patching.
  2. Add a "Pricing per shipping method" repeater section to `add-item.ftlh` mirroring what `edit-item.ftlh:127-171` already has.
  3. Extend `CreateItemRequest` with `List<ItemPriceDto> prices`.
  4. In `ItemServiceImpl.createItem`, initialize `item.setPrices(new ArrayList<>())` before calling `setItemPrices`, so the existing `.clear()` is safe even if the request omits prices.
  5. As a safety net, keep the form valid even with zero pricing rows (item still creatable; provider can add prices later from the edit screen).

### Task M3 — Fix the package-selection algorithm
**Symptom:** results are non-deterministic and ignore the per-shipping-method prices the user picked.

- Files:
  - `BE/src/main/java/com/builtin/service/impl/CalculatorServiceImpl.java:109-145` (the `matchToStore` greedy sort)
  - `BE/src/main/java/com/builtin/service/impl/AgentServiceImpl.java:208-245` (parallel logic)
  - `BE/src/main/java/com/builtin/service/impl/DealServiceImpl.java:135-140` (`effectivePrice`)
  - `BE/src/main/java/com/builtin/repository/ItemPriceRepository.java` (no `ORDER BY` on `findFirstByItemIdAndShippingMethod`)
- Changes:
  1. Introduce a single helper `effectivePrice(Item, ShippingMethod)` used by *both* the matcher and the deal-checkout code, returning the cheapest matching `ItemPrice.amount` for that method or falling back to `item.getPrice()`. Place it in a shared utility (e.g. `BE/src/main/java/com/builtin/util/Pricing.java`).
  2. Update `ItemPriceRepository` to add a deterministic ORDER BY `amount ASC` (rename method to `findFirstByItemIdAndShippingMethodOrderByAmountAsc` or use `@Query`).
  3. In both `matchToStore` implementations, sort candidates by `effectivePrice(item, requestedMethod)` instead of `Item::getPrice`. If the request doesn't specify a method, sort by min-over-methods.
  4. When building the returned `MatchedItem`, set its `price` from `effectivePrice(...)` not `item.getPrice()`.
  5. Add a null guard: if `item.getPrices()` is null/empty, the helper just returns base price — no NPE.
- Verify with a small fixture: item A has base $10 / IMMEDIATE $12, item B has base $11 / IMMEDIATE $9. Asking for IMMEDIATE must return B first. Today it returns A.

### Task M4 — Complete translations
**Symptom:** switching to he/ar/ru/zh leaves significant English text in the UI.

- Bundles (all currently 96 keys): `webApp/src/main/resources/messages.properties`, `messages_he.properties`, `messages_ar.properties`, `messages_ru.properties`, `messages_zh.properties`.
- Templates with hardcoded English (priority order, highest impact first):
  - `webApp/src/main/resources/templates/layout/main.ftlh:58,65,72` — nav items "Deliveries", "My Locations", "Track Order" (affects every page).
  - `webApp/src/main/resources/templates/delivery-dashboard.ftlh:5-9, 49, 84-108, 116-135, 155-287` — status badges, section headers, button labels, stage timeline labels (Freemarker arrays at the top of the file are hardcoded English).
  - `webApp/src/main/resources/templates/delivery-detail.ftlh:36-181` — breadcrumbs, "Order Total", courier/customer cards.
  - `webApp/src/main/resources/templates/order-tracking.ftlh:12-13, 34-43, 61-157` — page header, error states, stage labels.
  - `webApp/src/main/resources/templates/edit-item.ftlh:115` — "Locations are managed in My Locations" link.
- Subtasks (per template, one PR each is fine):
  1. Add new keys to `messages.properties` (English) for every hardcoded string, using a stable namespace like `nav.deliveries`, `delivery.stage.pending`, `tracking.no_record`, etc.
  2. Mirror the keys into the other four locale files with translations. For he/ar, double-check RTL rendering doesn't break (rtl.css is already in place — see `static/css/rtl.css`).
  3. Replace each hardcoded literal in the template with `<@spring.message "key"/>` (or the existing pattern used by `<@spring.message>` in already-translated templates).
  4. Move hardcoded Freemarker arrays for stage labels (`order-tracking.ftlh:41-44`, `delivery-dashboard.ftlh:14-16`) out of the template — either build them from message keys in the template, or expose them from the controller as a localized map.
- Verify: load each affected page in he, ar, ru, zh and confirm no English remains.

### Task M5 — Make GPS tracking actually render a map
**Symptom:** user reports "tracking using Google Maps is not working". The codebase uses **Leaflet/OpenStreetMap**, not Google Maps. **Decision: stay on Leaflet** — fix the existing implementation rather than switching providers (no API key / billing needed).

- Files:
  - `webApp/src/main/resources/templates/order-tracking.ftlh:3, 181-225` (map render + condition)
  - `webApp/src/main/resources/templates/delivery-detail.ftlh:3, 312-326, 382-396`
  - `webApp/src/main/resources/templates/delivery-dashboard.ftlh:359-374` (driver-side `navigator.geolocation` broadcast)
  - `webApp/src/main/java/com/builtin/webapp/controller/DeliveryDashboardController.java:108-123` (POST `/deliveries/location`)
  - `BE/src/main/java/com/builtin/service/impl/DeliveryServiceImpl.java:164-172` (lat/lng mapped to DTO)
  - `BE/src/main/java/com/builtin/model/DeliveryAccount.java:36-40` (lat/lng storage)
- Subtasks:
  1. Reproduce: start a delivery, accept it on a driver login, move it to `IN_DELIVERY`, open the order-tracking page on a customer login. Capture: which condition fails (`stage`, `driverLatitude`, `driverLongitude`), and is the geolocation POST actually firing?
  2. Add fallback UI in `order-tracking.ftlh:3` so when stage or coords are missing the page shows a clear "Driver location not yet available" panel instead of just no map.
  3. Fix the driver broadcast gating in `delivery-dashboard.ftlh:360` — today it only starts `watchPosition` when `inDeliveryCount > 0`, so a driver who just hit "Start delivery" needs a page reload before broadcasting starts.
  4. Confirm `DeliveryServiceImpl.toDto` is actually populating `driverLatitude`/`driverLongitude` — log a sample response while the driver is broadcasting.
  5. Self-host Leaflet (or pin via SRI) instead of `unpkg.com/leaflet@1.9.4` to remove the CDN as a failure mode.
  6. If geolocation is denied or HTTPS isn't available, surface the reason to the driver — today the broadcast silently fails.

### Task M6 — Clean up leftover debug scripts at repo root
**Symptom:** the repo root has loose `debug_bing.mjs`, `debug_bing2.mjs`, `debug_google.mjs`…`debug_google4.mjs`, `fetch_missing.mjs`, `fetch_photos.mjs`, `fetch_photos_google.mjs` files (visible from `ls`). These look like one-off photo-scraping scripts left over from earlier tasks.

- Subtasks:
  1. Quick grep across `webApp/`, `BE/`, `package.json`, CI files to confirm nothing references them.
  2. Read each one briefly to capture any logic worth preserving (e.g. as a doc) before deletion.
  3. Delete the files (and the matching entry in `package.json` `scripts`, if any).
  4. If any of the scripts are actually still useful (e.g. for re-fetching photos on demand), move them under `BE/scripts/` or `tools/` instead of deleting.
- Priority: lowest. Do last.

---

## Suggested execution order
M1 → M3 → M2 → M5 → M4 → M6. (M1 is a 5-line fix that unblocks correct behavior of M3 and M5; M4 can be done in parallel with any other task since it touches templates only; M6 is cleanup, do last.)

## Out of scope for this maintenance round
- iOS/Android app changes
- Schema migrations beyond what M2/M3 require (the `item_price` table already exists from Task 9)
- New features — only repairs

## How to verify the whole batch end-to-end after all 6 tasks land
1. Start BE (`cd BE && ./mvnw spring-boot:run`) and webApp (`cd webApp && ./mvnw spring-boot:run`).
2. Log in as a provider → create a new item with 2+ shipping-method prices → confirm item is saved with all `ItemPrice` rows.
3. Log in as a customer → use Calculator with that item → confirm it appears with the correct method-specific price → add to cart → confirm price toggles when shipping method changes.
4. Place an order → log in as a driver → accept → start delivery → broadcast GPS → as the customer, watch the tracking page render the map and the marker.
5. Switch language to he, ar, ru, zh on each of: home, products, cart, order-tracking, delivery-dashboard. Confirm no English remains.
