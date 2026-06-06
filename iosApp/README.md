# BuiltIn — iOS App

## Status
Phase 1 complete — scaffold, network layer, and all DTOs in place.

## Tech Stack
- **Language:** Swift 5.9
- **UI:** SwiftUI
- **Architecture:** MVVM + `@EnvironmentObject` AppState
- **Networking:** URLSession (native `async/await`)
- **Image loading:** Kingfisher
- **Min deployment:** iOS 17.0

## Project Setup

### Prerequisites
- Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

### Generate the Xcode project
```bash
cd iosApp
xcodegen generate
open BuiltIn.xcodeproj
```

### Configure the API base URL
By default the app points to `http://localhost:8080/api`.  
Override at runtime via the `API_BASE_URL` environment variable in the Xcode scheme editor.

## Structure
```
BuiltIn/
├── App/
│   ├── BuiltInApp.swift       # @main entry point
│   ├── AppState.swift         # Global state (user, cart)
│   └── RootView.swift         # Role-based tab routing
├── Config/
│   └── Config.swift           # Base URL
├── Network/
│   ├── APIClient.swift        # async/await HTTP client (actor)
│   ├── APIError.swift         # Typed error enum
│   └── Endpoint.swift         # All API endpoint paths
├── Models/
│   ├── UserDto.swift          # User + UserRole + LoginRequest
│   ├── ItemDto.swift          # Item + ItemPrice + Photo + enums
│   ├── ProviderDto.swift      # Provider + ProviderLocation
│   ├── CartDto.swift          # CartItem + CheckoutRequest
│   ├── DealDto.swift          # Deal + DealStatus
│   ├── DeliveryDto.swift      # Delivery + Account + Driver + enums
│   ├── CalculatorDto.swift    # Calculator request/response
│   └── AgentDto.swift         # AI Agent request/response
├── Views/                     # (Phase 2+)
├── ViewModels/                # (Phase 2+)
├── Services/                  # (Phase 2+)
└── Resources/
    └── Info.plist
```

## API
Consumes the same REST API as the web app at `http://<host>:8080/api`.

| Feature | Endpoints |
|---------|-----------|
| Auth | `POST /auth/login`, `POST /auth/logout` |
| Products | `GET /items`, `GET /items/{id}` |
| Providers | `GET /providers`, `GET /providers/{id}` |
| Cart / Checkout | `POST /deals/checkout` |
| Deliveries | `GET /deliveries`, `POST /deliveries/{id}/accept`, ... |
| Calculator | `POST /calculator/calculate` |
| AI Agent | `POST /agent/calculate` |
| Photos | `GET /photos/{filename}` |

## Build Phases
- [x] Phase 1 — Scaffold, Network Layer, DTOs
- [x] Phase 2 — Authentication
- [x] Phase 3 — Customer Flow (Home, Products, Cart, Tracking)
- [x] Phase 4 — AI Tools (Calculator, Agent)
- [x] Phase 5 — Visual & Localization Parity with WebApp
- [x] Phase 6 — Provider Flow
- [x] Phase 7 — Delivery Flow
- [x] Phase 8 — Admin Flow
- [x] Phase 9 — Polish (dark mode, accessibility)

### Phase 5 — Visual & Localization Parity with WebApp
Bring the iOS app's look-and-feel and language coverage to parity with the webApp surface (the post-maintenance state):
- **Logos & imagery:** import `webApp/src/main/resources/static/img/logo.svg` and `logo-icon.svg` into the iOS asset catalog; render the wordmark on `LoginView`, the icon as the app icon and nav-bar brand.
- **Color palette:** match the webApp's Bootstrap-derived palette — dark navbar, warning-yellow accent for primary actions, the same blue / green / red semantic colors used for delivery stages. Centralize as a `Theme` enum or `Color` extension so the existing views can adopt it without churn.
- **Languages:** ship `Localizable.strings` for `en` / `he` / `ar` / `ru` / `zh` covering every user-facing string in the views we have so far, mirroring the keys/values already in `webApp/src/main/resources/messages*.properties`. Wire a language picker in `ProfileView` (or the navbar) like the webApp's `?lang=` switcher; persist the choice in `UserDefaults`.
- **RTL:** verify `he` / `ar` lay out right-to-left (iOS handles this when `Localizable.strings` is present and the user picks an RTL language) — adjust any views that hard-code leading/trailing.
