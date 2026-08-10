# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app **`yellowspotuser`** (package: `yellowspotuser`) — the resident + admin mobile client for the YellowSpot parking management product. Single codebase serves three product surfaces selected at runtime: regular resident user, residential admin, and corporate admin.

- Flutter SDK pinned to **3.38.9** stable (CI matches; bump in both [`pubspec.yaml`](pubspec.yaml) `environment.sdk` and [`.github/workflows/`](.github/workflows/) when upgrading).
- State management: `flutter_riverpod` ^2.6 (StateNotifier + AsyncValue throughout).
- HTTP: `dio` ^5.9 via a single configured instance in [`lib/core/providers/app_providers.dart`](lib/core/providers/app_providers.dart).
- Session storage: `flutter_secure_storage`.

## Commands

```bash
flutter pub get                                    # install deps
flutter analyze                                    # static analysis (must pass — gates CI)
flutter test                                       # all unit tests
flutter test test/path/to/file_test.dart           # one test file
flutter test --plain-name 'substring of test name' # single test by name
dart format .                                      # format (CI does --output=none, non-blocking)

# Run / build — Google Maps key is required at compile time:
flutter run --dart-define=GOOGLE_MAPS_API_KEY=<key>
flutter build apk --release --dart-define=GOOGLE_MAPS_API_KEY=<key>
flutter build appbundle --release --dart-define=GOOGLE_MAPS_API_KEY=<key>
```

Read it in Dart via `String.fromEnvironment('GOOGLE_MAPS_API_KEY')` — **not** `Platform.environment`.

Environment is selected by editing `AppConfig.current` in [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart) (`localDev` / `uat` / `production`). Defaults to `uat`. Production must flip to `--dart-define` driven.

CI/release pipeline is documented in [`docs/CI_CD.md`](docs/CI_CD.md) — secrets, signing, Firebase distribution, tagging.

## Architecture

### Root routing — `AuthWrapper`

[`lib/features/auth/screens/auth_wrapper.dart`](lib/features/auth/screens/auth_wrapper.dart) is the only widget mounted from `main.dart`. It `select`s a 4-tuple `(isLoading, isLoggedIn, isAdmin, isCorporate)` from `AuthController` to avoid spurious rebuilds and dispatches to one of:

- `LoginScreen` (logged out)
- `CorporateAdminDashboardScreen` (solutionType == "CORPORATE", overrides admin toggle)
- `ResidentialAdminDashboardScreen` ↔ `HomeScreen` (admin role, toggled by `isAdminViewProvider`)
- `HomeScreen` (regular user)

`solutionType` lives on `AppUser` and gates corporate-only behavior. Backend casing is inconsistent — always compare via `.toUpperCase() == 'CORPORATE'` (see auth_wrapper for the canonical check).

### Feature folder convention

Every feature under `lib/features/<name>/` follows this layered split — keep it when adding code:

```
features/<name>/
  application/   # Riverpod controllers (StateNotifier), providers
  data/          # repositories + remote_data_sources (Dio calls)
  domain/        # plain Dart models / entities
  screens/       # ConsumerWidget / ConsumerStatefulWidget
  widgets/       # reusable widgets local to the feature
```

Top-level features: `admin`, `auth`, `corporate`, `parking`, `residential`, `services`, `map`, `core` (shared screens like `home_screen.dart`).

### Cross-cutting infrastructure — `lib/core/`

- **[`network/api_endpoints.dart`](lib/core/network/api_endpoints.dart)** — every backend path lives here. Always add new endpoints here, never inline string literals in repositories.
- **[`providers/app_providers.dart`](lib/core/providers/app_providers.dart)** — `dioProvider`, `secureStorageProvider`, `webSocketProvider` (`autoDispose` — connects on first listen, disconnects when none), `isAdminViewProvider` (residential admin's "Back to User" toggle), `activeRoleProvider`.
- **[`services/network/dio_interceptor.dart`](lib/core/services/network/dio_interceptor.dart)** — caches the JWT in memory, attaches `Authorization: Bearer …`, busts the cache on 401. Call `interceptor.setToken(...)` after login/refresh.
- **[`services/network/websocket_service.dart`](lib/core/services/network/websocket_service.dart)** — **stub**. The previous mock that overwrote real dashboard stats with random numbers has been neutralised. `AdminController` still subscribes to its stream so when a real WS endpoint is wired in here, live updates flow through unchanged.
- **[`network/api_exception.dart`](lib/core/network/api_exception.dart)** — every repo wraps `DioException` with `ApiException.fromDio(e, fallback: '...')`. Keep this pattern.

### API conventions (apply to every new repository)

- **Pagination shape** — repos accept three responses transparently: `content[]` (Spring `PagedModel` — preferred for new code), `_embedded.<name>`, or bare top-level list. See `_extractRows()` in any repo for the canonical helper.
- **Timestamps** — both ISO-8601 strings and Jackson `[y,m,d,h,m,s]` arrays are accepted; prefer ISO. `_parseDateTime()` lives in repos that need it (e.g. `admin_repository.dart`).
- **Money** — always integer paise (₹1 = 100 paise). Format only at the UI layer.
- **Images** — backend returns only an `imageId`; the app resolves a presigned URL via `GET /api/v1/images/preview/{imageId}`. `ImagePreviewScreen` already handles this.
- **Tenant headers** — `subdomain` and `customerCode` are currently hardcoded to `"demo"` in `DioInterceptor`. Multi-tenant builds will need this driven by `--dart-define` or JWT claims.
- **TLS** — `dioProvider` installs `badCertificateCallback => true` in debug + non-prod only (the UAT host's CA isn't in OS root stores). Production must hit a properly chained cert.

### Residential vs Corporate — shared screens

The corporate dashboard reuses the same tenant/vehicle/smart-card APIs as residential. Only labels and one entry-point screen differ:

- **`ResidentsListScreen`** ([`lib/features/admin/residents/screens/`](lib/features/admin/residents/screens/)) takes optional `entityLabelSingular` / `entityLabelPlural` constructor params (default `'Resident'`/`'Residents'`). Corporate passes `'Employee'`/`'Employees'`. Same provider, same endpoint.
- **`CorporateEntryExitScreen`** reads `ParkingLogRow` from `corporateDashboardProvider` (which calls `/dashboard/parking-logs`) and feeds the shared `EntryExitListItem` widget. Residential's entry/exit reads its own `entryExitDataProvider`.
- **Tenant `type` field casing** — `/api/v1/tenants` returns `'tenant'` / `'owner'` lowercase, but the AddResidentScreen dropdown items use `'Tenant'` / `'Owner'`. Always normalise via the `_canonicalType()` helper pattern (case-insensitive lookup with a fallback) before binding to a `DropdownButtonFormField` value — otherwise the assert `'items.where(...).length == 1'` fires.
- Logout lives **only** in `ProfileScreen`. Both dashboards show `UserAvatarButton` (top-right) which pushes ProfileScreen. Don't reintroduce logout icons elsewhere.
- **Post-logout navigation** — after `AuthController.logout()`, callers must `Navigator.popUntil((r) => r.isFirst)` so `AuthWrapper`'s rebuilt `LoginScreen` is on top. See the logout button in `profile_screen.dart` for the canonical pattern.

### Mock vs real surfaces

[`docs/API_INTEGRATION_GAPS.md`](docs/API_INTEGRATION_GAPS.md) is the authoritative inventory of which screens are wired vs still mocked, the proposed backend contracts, and a sprint-ordered delivery plan. Read it before assuming an endpoint exists — several visible screens (Residential home, Parking spots/booking/payment, Quick Services, Admin Requests, Admin Security) are still backed by repository mocks.

Mock services live under [`lib/core/services/mock/`](lib/core/services/mock/), real ones under [`lib/core/services/api/`](lib/core/services/api/) — when promoting a mock to real, switch the provider binding rather than editing the mock in place.

### Multi-role users

`AppUser.roles` is a `List<UserRole>` — accounts can hold `user` + `admin` simultaneously. The admin/user toggle in residential is `isAdminViewProvider` (a `StateProvider<bool>`); on login it's auto-flipped to `true` for admin accounts (see `AuthController._restoreSession` / `login`). Corporate ignores this toggle — corporate accounts always land on the corporate dashboard.

## Notes for editing

- **Always run `flutter analyze`** before declaring work done. CI fails on warnings; the codebase has known pre-existing `info`-level `withOpacity` deprecation lints under `lib/features/parking/**`, `lib/features/residential/**`, `lib/features/services/**` — don't introduce new ones, and don't waste cycles trying to fix those unless asked.
- When adding endpoints, add them to `ApiEndpoints` first, then call from a `*_remote_data_source.dart` or `*_repository.dart`, then expose a Riverpod provider — never call `Dio` directly from a widget.
- For new dashboard cards / metrics, follow the residential `_VehiclesStatCard` tappable pattern (cycles total → subtype counts) — the visual idiom is established.
- Theme tokens (yellow brand, M3 colorSchemeSeed, white cards with grey-200 borders) are defined in [`lib/main.dart`](lib/main.dart). Pull from `Theme.of(context)` rather than hardcoding colors per screen.
