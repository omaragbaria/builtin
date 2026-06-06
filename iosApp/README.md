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
- [ ] Phase 5 — Provider Flow
- [ ] Phase 6 — Delivery Flow
- [ ] Phase 7 — Admin Flow
- [ ] Phase 8 — Polish (i18n, dark mode, accessibility)
