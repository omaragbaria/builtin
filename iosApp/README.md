# BuiltIn — iOS App

This folder is reserved for the future iOS application.

## Status
Planned — not yet started.

## Tech Stack (planned)
- **Language:** Swift
- **UI:** SwiftUI
- **Architecture:** MVVM
- **Networking:** URLSession / Alamofire → BuiltIn REST API (`http://<host>:8080/api`)

## API
The iOS app will consume the same REST API as the web app:

| Feature | Endpoint |
|---------|---------|
| Products | `GET /api/items` |
| Product detail | `GET /api/items/{id}` |
| Cart / Checkout | `POST /api/deals/checkout` |
| AI Assistant | `POST /api/agent/calculate` |

## Getting Started
_(Instructions will be added when development begins)_
