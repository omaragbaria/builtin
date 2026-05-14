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
- [ ] 4.1 Customer view: show current stage, ETA, and delivery details for their order
- [ ] 4.2 Admin view: show all active deliveries with stage, ETA, and assigned delivery account
- [ ] 4.3 Delivery account view: show their assigned packages and allow stage/ETA updates
- [ ] 4.4 Real-time or polling updates when stage or ETA changes

---

## Task 5 — Delivery Page (Frontend)

Build the delivery tracking page accessible to all three roles.

**Subtasks:**
- [ ] 5.1 Design and implement the delivery status page
- [ ] 5.2 Role-based rendering (customer / admin / delivery account)
- [ ] 5.3 Display package details, current stage, and ETA
- [ ] 5.4 Add stage update controls for delivery accounts
