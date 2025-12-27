Single-screen Flutter application that shortens URLs using a backend service and keeps an **in-memory history** of recently shortened links.

## Features

- Shorten a URL via backend (`POST /api/alias`)
- In-memory history of recently shortened links (cleared when the app restarts)
- Typed error mapping (network / bad request / unexpected)
- Clean Architecture-inspired layering (domain / data / presentation)
- Unit tests + widget tests
- CI on Pull Requests mirroring local quality checks

## Requirements

- **Flutter (stable channel)** — recommended: the same version used by CI.
- A backend service compatible with:
    - `POST /api/alias`
    - JSON body: `{ "url": "https://example.com" }`
    - JSON response: `{ "alias": "abc123" }`

### Check your Flutter version

    flutter --version

If you want to align with CI, open `.github/workflows/ci.yml` and use the same Flutter version specified there.

## Setup

### 1) Install dependencies

    flutter pub get

### 2) Configure backend URL (recommended)

The app reads the backend URL from a compile-time define:

- `API_BASE_URL` (example: `https://your-host.com`)

  flutter run --dart-define=API_BASE_URL=https://your-host.com

If `API_BASE_URL` is not provided, the app falls back to the default configured in `ApiConfig`.

## Run

    flutter run --dart-define=API_BASE_URL=https://your-host.com

## Quality checks (local)

This repository uses a single command to enforce formatting, static analysis, and tests.

    make check

What it does (high-level):

- `flutter pub get`
- `dart format .`
- `flutter analyze --no-pub`
- `flutter test --no-pub`

## CI (GitHub Actions)

CI runs on Pull Requests and mirrors the same checks executed by `make check`.
You can review the result under the **Actions** tab or inside the PR **Checks** section.

## Project structure

Clean Architecture-inspired layout:

- `lib/src/core/`
    - `errors/`: typed failures/exceptions
    - `http/`: API config
- `lib/src/features/url_shortener/`
    - `domain/`: entities, repository contracts, use cases, validators
    - `data/`: models/DTOs, datasource, repository implementation
    - `presentation/`: Cubit, pages, widgets
- `lib/src/di.dart`: dependency registration (GetIt)
- `test/`: unit tests + widget tests mirroring the feature structure

## Backend contract

Expected request:

- `POST /api/alias`
- Body: `{ "url": "<absolute http(s) url>" }`

Expected response:

- `201` (or `200`)
- Body: `{ "alias": "<string>" }`

## Notes

- History is intentionally in-memory (per requirements).
- The project prioritizes deterministic validation and testable layers.
