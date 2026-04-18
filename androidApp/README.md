# BuiltIn — Android App

This folder is reserved for the future Android application.

## Status
Planned — not yet started.

## Tech Stack (planned)
- **Language:** Kotlin
- **UI:** Jetpack Compose
- **Architecture:** MVVM + Repository pattern
- **Networking:** Retrofit → BuiltIn REST API (`http://<host>:8080/api`)

## API
The Android app will consume the same REST API as the web app:

| Feature | Endpoint |
|---------|---------|
| Products | `GET /api/items` |
| Product detail | `GET /api/items/{id}` |
| Cart / Checkout | `POST /api/deals/checkout` |
| AI Assistant | `POST /api/agent/calculate` |

## Getting Started
_(Instructions will be added when development begins)_
