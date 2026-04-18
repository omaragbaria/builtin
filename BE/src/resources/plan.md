# Project Plan — BuiltIn

---

## Feature 1: AI Agent (Materials Calculator)

**Goal:** Allow users to describe a woodworking/construction project in natural language. The agent calculates the required materials, fetches matching products from the store, and lets the user add them to the cart.

**Example interaction:**
> "I want to build a wall closet from oak wood — 4m wide, 60cm deep, 1.8m high."
> → Agent returns: oak wood panels (quantity), screws (count), glue (units), etc. — all with the lowest available price and an "Add to Cart" button.

### Tasks

- [x] **1.1** Set up AI agent service (mock ChatGPT API for now, swap later with real key)
- [x] **1.2** Build the prompt logic — parse user input for material type, dimensions, and project type
- [x] **1.3** Implement material calculation engine — given dimensions, return a list of required materials with quantities
- [x] **1.4** Map calculated materials to real store products (match by type, find lowest price)
- [x] **1.5** Create API endpoint: `POST /agent/calculate` — accepts natural language input, returns materials list with product matches
- [x] **1.6** Add "Add all to cart" and per-item "Add to cart" actions on the response

---

## Feature 2: Shipping Options

**Goal:** When a customer clicks "Buy Now" on the cart, they can choose a shipping method. Items in the cart are grouped by compatible shipping time, and each product has a `shippingTime` field.

### Shipping Methods
| Option | Delivery Time |
|--------|--------------|
| Immediate | Within 24 hours |
| Fast | 2–5 business days |
| Standard | (to be defined) |

### Tasks

- [x] **2.1** Add `shippingTime` field to the Product model/schema
- [x] **2.2** Seed/update existing products with appropriate `shippingTime` values *(column added; set per product via edit-item form or API)*
- [x] **2.3** On the cart page — group cart items by `shippingTime` and display them in sections
- [x] **2.4** Create shipping options selection UI (Immediate / Fast / Standard)
- [x] **2.5** Create API endpoint: `POST /orders/checkout` — accepts cart + selected shipping option, validates compatibility
- [x] **2.6** Store the chosen shipping method on the order record

---

## Feature 3: Mobile App Scaffolding

**Goal:** Create placeholder project folders for future Android and iOS apps.

### Tasks

- [x] **3.1** Create `/androidApp` folder — base Android project structure (empty scaffold)
- [x] **3.2** Create `/iosApp` folder — base iOS project structure (empty scaffold)
- [x] **3.3** Add a `README.md` inside each folder explaining it is reserved for future mobile development

---

## Priority Order

1. Feature 2 — Shipping (lower complexity, builds on existing cart)
2. Feature 1 — AI Agent (core differentiator, needs more design)
3. Feature 3 — Mobile Scaffolding (quick, non-blocking)
