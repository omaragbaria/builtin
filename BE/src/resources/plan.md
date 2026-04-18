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

## Feature 4: Construction Materials Calculator

**Goal:** Allow users to input structural dimensions (e.g. roof size, wall area) and get an accurate calculation of the required concrete, iron/rebar, and other materials. The result includes matched store products with an option to add them to the cart.

**Example interaction:**
> "I need to pour a concrete roof — 8m × 6m, 20cm thick."
> → Calculator returns: concrete volume (m³), iron rebar (kg/count), wire mesh, formwork — all matched to the lowest-price store products with "Add to Cart" buttons.

### Supported Structures (v1)
| Structure | Inputs | Outputs |
|-----------|--------|---------|
| Flat roof slab | Length × Width × Thickness | Concrete (m³), Iron rebar (kg), Wire mesh (m²) |
| Wall | Length × Height × Thickness | Concrete (m³), Iron rebar (kg), Blocks (units) |

> More structure types (columns, footings, stairs) can be added in future iterations.

### Material Types (v1)
- Concrete (calculated in m³)
- Iron / Rebar (calculated in kg, with standard bar sizes)
- *(Extensible — new material types added per structure in future)*

### Tasks

- [x] **4.1** Define calculation formulas for each structure type (roof slab, wall) — concrete volume, rebar weight, mesh area
- [x] **4.2** Create `CalculatorRequest` model — structure type, dimensions, unit system
- [x] **4.3** Create `CalculatorResult` model — list of materials with quantity, unit, and matched store products
- [x] **4.4** Implement calculator service — pluggable per structure type, easy to extend
- [x] **4.5** Map calculated materials to real store products (same matching logic as Agent Feature 1)
- [x] **4.6** Create API endpoint: `POST /calculator/calculate` — accepts structure type + dimensions, returns materials list with product matches
- [x] **4.7** Build calculator UI page — form for structure type + dimensions, results section with add-to-cart buttons
- [x] **4.8** Add "Add all to cart" and per-item "Add to cart" on the calculator results

---

## Priority Order

1. Feature 2 — Shipping ✅ (done)
2. Feature 1 — AI Agent ✅ (done)
3. Feature 3 — Mobile Scaffolding ✅ (done)
4. Feature 4 — Construction Materials Calculator ✅ (done)