# Shipping Feature — Implementation Plan

## Overview

When a customer has a cart ready for checkout, they are presented with shipping options. Each option may differ in delivery timeframe, packaging style, and pricing (based on what the provider can fulfill within that period).

---

## Task 1 — Shipping Options at Checkout

Allow customers to choose a shipping method when placing an order.

**Subtasks:**
- [x] 1.1 Add shipping selection step to the checkout flow
- [x] 1.2 Implement the four shipping options:
  - Self pickup
  - Express (within 24 hours)
  - Standard (2–5 business days)
  - Economy (up to 14 days)
- [x] 1.3 Display packaging style per option
- [x] 1.4 Calculate and display pricing per option (based on provider rates for the chosen timeframe)
- [x] 1.5 Persist the selected shipping method on the order record

---

## Task 2 — Delivery Account Type

Introduce a new `DeliveryAccount` user type that extends the base `User` model.

**Subtasks:**
- [x] 2.1 Extend the `User` model with a `DeliveryAccount` type
- [x] 2.2 Add account subtype field: `company` or `freelance`
- [x] 2.3 For **company** accounts: support assigning multiple drivers (name + phone number per driver)
- [x] 2.4 For **freelance** accounts: single driver profile (name + phone number)
- [x] 2.5 Add vehicle type field with the following options:
  - Bike
  - Motorbike
  - Normal car
  - Truck
  - Large truck (12+ ton)
  - Two-trailer truck
  - Fridge truck
  - Mixed truck
  - Truck with winch
- [x] 2.6 Add authentication & registration flow for delivery accounts

---

## Task 3 — Delivery Actions (Delivery Account Capabilities)

Allow delivery accounts to manage packages assigned to them.

**Subtasks:**
- [x] 3.1 Accept a package that is waiting for a delivery assignment
- [x] 3.2 Update package delivery stage:
  - `Accepted`
  - `In Delivery`
  - `Arrived`
- [x] 3.3 Set / update ETA for the delivery

---

## Task 4 — Delivery Tracking & Visibility

Expose delivery status information to relevant parties.

**Subtasks:**
- [x] 4.1 Customer view: show current stage, ETA, and delivery details for their order
- [x] 4.2 Admin view: show all active deliveries with stage, ETA, and assigned delivery account
- [x] 4.3 Delivery account view: show their assigned packages and allow stage/ETA updates
- [x] 4.4 Real-time or polling updates when stage or ETA changes

---

## Task 5 — Delivery Page (Frontend)

Build the delivery tracking page accessible to all three roles.

**Subtasks:**
- [x] 5.1 Design and implement the delivery status page
- [x] 5.2 Role-based rendering (customer / admin / delivery account)
- [x] 5.3 Display package details, current stage, and ETA
- [x] 5.4 Add stage update controls for delivery accounts

---

## Task 6 — GPS Parcel Tracking

Integrate real-time GPS-based tracking so customers can follow their parcel on a live map.

**Subtasks:**
- [x] 6.1 Integrate a mapping library for live parcel tracking (Google Maps preferred; fall back to an alternative if not feasible)
- [x] 6.2 Expose the driver's current GPS coordinates from the delivery account in real time
- [x] 6.3 Display the live map on the customer's delivery tracking page, showing the driver's current position and the destination
- [x] 6.4 Keep the driver's position updated periodically while the delivery is in progress (polling or WebSocket)

---

## Task 7 — Immediate Pickup Mode

Add a new shipping option — **Immediate** — that automatically assigns the order to the nearest available driver based on the delivery address, with no manual acceptance step.

**Subtasks:**
- [x] 7.1 Add `Immediate` as a selectable shipping method at checkout
- [x] 7.2 On order placement, calculate which available driver is geographically closest to the delivery address using GPS coordinates
- [x] 7.3 Automatically push the package assignment to that driver
- [x] 7.4 Handle the case where no nearby driver is available: notify the customer and offer alternative shipping methods

---

## Task 8 — Item & Provider Location Management

Attach structured location data to both items and providers, so the system knows where stock physically exists. This is a prerequisite for proximity-based driver assignment in Task 7.

**Subtasks:**
- [ ] 8.1 Add a `locations` array field to the **Provider** model. Each entry represents a branch or storage site and includes: `country`, `city`, `zipCode`, `gpsCoordinates` (lat/lng), and an optional `label`
- [ ] 8.2 Add the same `locations` array field to the **Item** model
- [ ] 8.3 When a new item is created, default its location to the adding provider's primary location
- [ ] 8.4 Allow providers to edit item locations and assign one or more of their registered locations to each item
- [ ] 8.5 Surface item location data to the nearest-driver calculation used in Task 7

---

## Task 9 — Multi-Provider Pricing per Item

Replace the single item price with a structured price list, supporting multiple providers offering the same item at different prices tied to specific delivery timeframes.

**Subtasks:**
- [ ] 9.1 Replace the single `price` field on Item with a `prices` array. Each entry contains: `amount`, `currency`, `deliveryTime` (e.g. `"Express – 24h"`, `"Standard – 2–5 days"`), and `providerId`
- [ ] 9.2 Apply the following display rules in the item listing UI:
  - If only one price exists → show it as-is
  - If multiple prices exist → show the lowest price prominently, with its corresponding delivery timeframe displayed beneath it in smaller text
- [ ] 9.3 At checkout, filter the price list to show only entries that match the customer's selected shipping method
- [ ] 9.4 Persist the selected provider's price and delivery timeframe on the order record
