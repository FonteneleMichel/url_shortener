# URL Shortener (Flutter)

Single-screen Flutter application that shortens URLs using a backend service and keeps an **in-memory history** of recently shortened links.

## Features

- Shorten a URL via backend (`POST /api/alias`)
- In-memory history of recently shortened links (cleared when the app restarts)
- Typed error mapping (network / bad request / unexpected)
- Clean Architecture-inspired layering (domain / data / presentation)
- Unit tests + widget tests
- CI on Pull Requests mirroring local quality checks
- Golden tests for UI regression

## Requirements

- Flutter (stable channel) — recommended: the same version used by CI.
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

Run passing the define:

    flutter run --dart-define=API_BASE_URL=https://your-host.com

If `API_BASE_URL` is not provided, the app falls back to the default configured in `ApiConfig`.

## Run

    flutter run --dart-define=API_BASE_URL=https://your-host.com

## Quality checks (local)

Run the full quality gate (format + analyze + tests):

    make check

This mirrors what runs in CI on Pull Requests.

## Golden tests

This project includes golden tests for UI regression.

Golden images can be sensitive to platform rendering differences (e.g. macOS vs Linux).  
To reduce CI mismatches, prefer updating goldens using the same environment as GitHub Actions (Linux).

### Update goldens (recommended: Docker / Linux)

Requirements:
- Docker Desktop running

Set the image and command (keeps lines short):

    IMAGE=ghcr.io/cirruslabs/flutter:stable
    CMD='flutter pub get && flutter test --update-goldens test/src/features/url_shortener/presentation/pages/url_shortener_page_golden_test.dart'

Run:

    docker run --rm --platform linux/amd64 -v "$PWD":/app -w /app "$IMAGE" bash -lc "$CMD"

After updating, commit the generated golden files.

### Run tests locally (no Docker)

    make check

## CI (GitHub Actions)

CI runs on Pull Requests and mirrors the same checks executed by `make check`.  
You can review results under the Actions tab or inside the PR Checks section.

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
