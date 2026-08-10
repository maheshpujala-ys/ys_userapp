# YellowSpot User App — Remaining API Integration Spec

**Audience:** Backend engineering
**Author:** Mobile team (Flutter)
**Last updated:** 2026-05-21
**App base path:** `lib/`
**HTTP client:** Dio 5.9 (multi-tenant headers: `subdomain`, `customerCode`)
**Auth:** Bearer JWT in `Authorization` header (via `DioInterceptor`)

---

## 1. Purpose & Scope

This document inventories every UI surface in the mobile app whose data is still **mocked** or **only locally persisted**, and proposes the API contract required to wire each one to a real backend.

The list below is the *delta* against the already-integrated surface (Auth, Admin Dashboard, Tenants/Residents, Vehicles, Smart Cards, Admin Users, Parking Logs, User Logs, Image Preview — see `lib/core/network/api_endpoints.dart`).

Each section follows the same pattern so the backend dev can scope endpoint-by-endpoint:

> **UI source** → **Form/Display fields** → **Proposed endpoint(s)** → **Request / response schema** → **Notes & open questions**

All endpoints assume the existing pattern: `/api/v1/...`, JSON body, Spring `PagedModel`-style pagination (`content[]`, `page`, `size`, `totalElements`), Jackson `LocalDateTime` arrays accepted (`[yyyy, MM, dd, HH, mm, ss]`).

---

## 2. Executive Summary — Gap Map

| # | Domain | Module(s) | UI status | API status | Priority |
|---|--------|-----------|-----------|------------|----------|
| 1 | Resident Home (society, unit, owner) | `features/residential` | Built | **Mocked** | P0 |
| 2 | My Vehicles (resident-scoped) | `features/residential` | Built | **Mocked** | P0 |
| 3 | Smart Access Card (resident-scoped) | `features/residential` | Built | **Mocked** | P1 |
| 4 | Visitor Pass — Generate QR (resident) | `features/residential` | Button only | **Missing** | P0 |
| 5 | Visitor Spot booking (resident) | `features/residential` | Button only | **Missing** | P1 |
| 6 | Parking — Nearby spots (map + list) | `features/parking` | Built | **Mocked** | P0 |
| 7 | Parking — Spot details / availability | `features/parking` | Built | **Mocked** | P0 |
| 8 | Parking — Book a spot | `features/parking` | Built | **Missing** | P0 |
| 9 | Parking — Payment (Pay Now / Pay Later) | `features/parking` | Built | **Missing** | P0 |
| 10 | Optional services on booking (EV / Wash / Valet) | `features/parking` | Built | **Missing** | P1 |
| 11 | Quick Services — Featured + Other (bill pay) | `features/services` | Built | **Mocked** | P2 |
| 12 | Recent Transactions | `features/services` | Built | **Mocked** | P1 |
| 13 | Emergency Services directory | `features/services` | Built | **Static, OK** | — |
| 14 | EV Charging — stations near unit | `features/residential` | Built | **Missing** | P1 |
| 15 | Car Services / Book a Car (external deep-links) | `features/services` | Built | **Static, OK** | — |
| 16 | Admin → Requests (join / vehicle-addition approvals) | `features/admin/requests` | Built | **Mocked** | P0 |
| 17 | Admin → Security (cameras, alerts, storage) | `features/admin/security` | Built | **Mocked** | P2 |
| 18 | Profile Update (Edit Profile) | `features/auth` | Built | **Local-only — no API call** | P0 |
| 19 | Forgot Password (true reset via email/OTP) | `features/auth` | Renamed to Change Password | **Missing real flow** | P1 |
| 20 | Notifications (bell icon, list, read state) | `features/parking` (top bar), global | Icon only | **Missing** | P1 |

Legend — **P0** = blocker for production, **P1** = launch-week, **P2** = post-launch.

---

## 3. Cross-cutting Concerns (read first)

These apply to every new endpoint below.

### 3.1 Auth & multi-tenancy
- All authenticated calls already carry `Authorization: Bearer <jwt>`. Continue to scope every new resource by the JWT's `customerId` / `tenantId` claim on the server side. The app does not pass tenant IDs in URLs.
- The current hardcoded `subdomain: "demo"` / `customerCode: "demo"` headers must keep working. They are set in `DioInterceptor`.

### 3.2 Pagination
- Use Spring `Pageable` — `?page=0&size=20`. Response body in the `PagedModel` shape:
  ```json
  { "content": [...], "page": 0, "size": 20, "totalElements": 137, "totalPages": 7 }
  ```
- The admin repository already accepts three shapes (`content`, `_embedded.<name>`, bare list) — pick one and stay consistent. Recommendation: `content[]`.

### 3.3 Timestamps
- Accepted shapes (mobile already parses both): ISO-8601 string (`"2026-05-13T12:09:04"`) or Jackson array (`[2026,5,13,12,9,4]`). **Prefer ISO strings** for new endpoints.

### 3.4 Money
- Always integer **paise** (₹1 = 100 paise) in JSON; the mobile app handles formatting. Never send pre-formatted strings like `"₹40/hour"`.

### 3.5 Error contract
- Return `{ "message": "...", "code": "DOMAIN_ERROR_KEY" }` with HTTP 4xx/5xx. `ApiException.fromDio` already extracts `message`.

### 3.6 Image references
- Whenever a response carries an image, return only the `imageId`. The app calls `GET /api/v1/images/preview/{imageId}` to resolve a presigned URL. Do not embed base64.

### 3.7 WebSocket events
- The app already has a single auto-dispose WebSocket (`core/services/network/websocket_service.dart`). Any real-time surface below (entry/exit, notifications, parking occupancy) should be pushed on the same connection with a discriminator field, e.g. `{ "topic": "parking.occupancy", "payload": {...} }`.

---

## 4. Detailed Endpoint Specs

### 4.1 Resident — Society & Unit Profile

**UI:** `features/residential/screens/residential_screen.dart`
**Currently mocked at:** `features/residential/data/residential_repository.dart` → `getResidentialData()`

**Fields displayed:**
- `society` — string (e.g. "Phoenix Heights")
- `unit` — string (e.g. "Unit B-1204")
- `ownerName` — string

**Proposed endpoint**
```
GET /api/v1/me/residence
```

**Response**
```json
{
  "tenantId": 142,
  "ownerName": "Rajesh Kumar",
  "tenantType": "OWNER",
  "society": "Phoenix Heights",
  "locationId": 7,
  "tower": "B",
  "floor": "12",
  "flat": "1204",
  "unitLabel": "Unit B-1204",
  "email": "raj@example.com",
  "mobile": "+919999999999",
  "altMobile": null,
  "address": "Plot 7, Gachibowli, Hyderabad"
}
```

**Notes**
- The unit label is derived server-side so the mobile doesn't need to format `B-1204`.
- This endpoint is the resident's *own* tenant record (driven by the JWT user → tenant link). Backend may already have `GET /tenants/{id}` — we need the "me" variant to avoid leaking the id.

---

### 4.2 Resident — My Vehicles

**UI:** `features/residential/screens/residential_screen.dart` → `_buildMyVehicles`
**Model:** `features/residential/domain/vehicle.dart` (`Vehicle { number, type, plateType, isActive }`)

**Fields per row:**
- `number` — string (license plate)
- `type` — enum: `FOUR_WHEELER | TWO_WHEELER`
- `plateType` — enum: `PRIVATE | EV | TAXI`
- `isActive` — bool

**Proposed endpoint**
```
GET /api/v1/me/vehicles?page=0&size=20
```

**Response (paged)**
```json
{
  "content": [
    {
      "registrationId": 91,
      "vehicleNumber": "TS09ER1234",
      "vehicleType": "FOUR_WHEELER",
      "plateType": "EV",
      "registrationType": "PERMANENT",
      "startDate": "2024-01-15",
      "endDate": null,
      "smartCardId": 12,
      "activeInd": true
    }
  ],
  "page": 0, "size": 20, "totalElements": 3
}
```

**Notes**
- Backend may simply call this `GET /api/v1/vehicle?tenantId=<me>`; we just need server-side filtering so the resident never sees other tenants' vehicles.
- `plateType` is new — currently the `/vehicle` endpoint doesn't return it. Either extend the existing DTO or expose it here.

---

### 4.3 Resident — Smart Access Card (RFID)

**UI:** `residential_screen.dart` → `_buildSmartAccessCard`

**Fields displayed:**
- `cardType` (e.g. "RFID Tag")
- `issuedDate`
- `status` (Active/Inactive)
- "View QR Code" CTA — payload TBD

**Proposed endpoint**
```
GET /api/v1/me/smart-card
```

**Response**
```json
{
  "smartCardId": 12,
  "cardNumber": "RF-00012",
  "serialNumber": "SN-AB12CD",
  "cardType": "RFID",
  "allocationStatus": "ALLOCATED",
  "issuedDate": "2024-01-15",
  "qrPayload": "ysp:card:12:HMAC-sig",
  "activeInd": true
}
```

**Notes**
- `qrPayload` should be an HMAC-signed token so the security gate scanner can verify offline. Spec the signing scheme separately.
- Returns 404 if the resident has no card; the UI should handle the empty state (currently it always renders — needs a small mobile change).

---

### 4.4 Resident — Generate Visitor Pass (QR)

**UI:** `residential_screen.dart` → `_buildActionCards` → "Visitor Pass / Generate QR" button (currently snackbar only).
**Related admin endpoint:** `POST /api/v1/registrations` (already wired in admin module for visitor entries).

**Proposed endpoint**
```
POST /api/v1/me/visitor-passes
```

**Request**
```json
{
  "visitorName": "Anil Verma",
  "visitorMobile": "+919876543210",
  "vehicleNumber": "TS10AB1234",
  "vehicleType": "FOUR_WHEELER",
  "purpose": "GUEST",
  "validFrom": "2026-05-22T09:00:00",
  "validTo":   "2026-05-22T22:00:00"
}
```

**Response**
```json
{
  "passId": 4421,
  "qrPayload": "ysp:visitor:4421:HMAC-sig",
  "validFrom": "2026-05-22T09:00:00",
  "validTo":   "2026-05-22T22:00:00",
  "shareUrl":  "https://uat.yellowspottech.com/p/4421"
}
```

**Notes**
- Server creates the registration server-side (don't expose the underlying `tenantId` field).
- Need a `GET /api/v1/me/visitor-passes?active=true` companion endpoint so residents can see/revoke active passes — UI not yet built; flag for next iteration.

---

### 4.5 Parking — Nearby Spots (map + list)

**UI:** `features/parking/screens/find_your_spot_screen.dart`, `find_spot_screen.dart`
**Currently mocked at:** `features/parking/data/parking_repository.dart` → `getNearbyParking()`

**Fields displayed per spot:**
- `mallName` (display name)
- `address`
- `distance` (km, derived client-side from current LatLng)
- `availability` (e.g. "45 Available")
- `price` (e.g. "₹40/hour" or "Free")
- `latlng` (for marker)

**Proposed endpoint**
```
GET /api/v1/parking/spots?lat=17.385&lng=78.486&radiusKm=10&page=0&size=50
```

**Response**
```json
{
  "content": [
    {
      "spotId": 4012,
      "name": "GVK One Mall",
      "address": "Banjara Hills, Road No. 1, Hyderabad, Telangana 500034",
      "lat": 17.4173,
      "lng": 78.4497,
      "totalSlots": 100,
      "availableSlots": 45,
      "hourlyRatePaise": 3000,
      "baseFeePaise": 3000,
      "freeOfCharge": false,
      "openingHours": "OPEN_24_7",
      "amenities": ["EV_CHARGE", "CAR_WASH", "VALET"],
      "imageId": "spot-4012-cover"
    }
  ],
  "page": 0, "size": 50, "totalElements": 12
}
```

**Notes**
- Distance is computed on the device — do not send it.
- `amenities` drives the optional-services chips on the booking screen.
- Use Haversine on the server for `radiusKm`; consider PostGIS if you already have spatial indexes.

---

### 4.6 Parking — Spot Detail

**UI:** `features/parking/screens/book_spot_screen.dart` (currently hardcoded values: "GVK One Mall", "45 Available", "Open 24/7")

**Proposed endpoint**
```
GET /api/v1/parking/spots/{spotId}
```

**Response** — same as a single element from §4.5, plus:
```json
{
  "...all fields above...",
  "termsUrl": "https://...",
  "amenityRatesPaise": { "EV_CHARGE": 5000, "CAR_WASH": 15000, "VALET": 10000 },
  "supportedDurationsMins": [60, 120, 240, 360, 480, 1440]
}
```

---

### 4.7 Parking — Quote / Price Breakdown

**UI:** `book_spot_screen.dart` → `_buildPriceBreakdown` (currently hardcoded ₹30 + ₹30)

A pure compute endpoint, so the UI can match the server's final amount exactly (no float drift, supports promo codes later).

**Proposed endpoint**
```
POST /api/v1/parking/quote
```

**Request**
```json
{
  "spotId": 4012,
  "vehicleNumber": "TS09ER1234",
  "durationMins": 120,
  "amenities": ["EV_CHARGE"],
  "promoCode": null
}
```

**Response**
```json
{
  "quoteId": "qt_01HXYZ...",
  "baseFeePaise": 3000,
  "durationFeePaise": 3000,
  "amenitiesFeePaise": 5000,
  "discountPaise": 0,
  "totalPaise": 11000,
  "currency": "INR",
  "expiresAt": "2026-05-21T12:35:00"
}
```

**Notes**
- `quoteId` is what the booking endpoint accepts — server re-validates price.

---

### 4.8 Parking — Confirm Booking

**UI:** `book_spot_screen.dart` → "Confirm Booking" CTA. Payment options: Pay Now / Pay Later.

**Proposed endpoint**
```
POST /api/v1/parking/bookings
```

**Request**
```json
{
  "quoteId": "qt_01HXYZ...",
  "vehicleNumber": "TS09ER1234",
  "paymentMode": "PAY_NOW"  // or "PAY_LATER"
}
```

**Response (PAY_NOW)**
```json
{
  "bookingId": 88123,
  "status": "AWAITING_PAYMENT",
  "totalPaise": 11000,
  "payment": {
    "provider": "RAZORPAY",
    "orderId": "order_LX...",
    "keyId": "rzp_test_...",
    "amountPaise": 11000
  },
  "qrPayload": null
}
```

**Response (PAY_LATER)**
```json
{
  "bookingId": 88123,
  "status": "CONFIRMED",
  "totalPaise": 11000,
  "payment": null,
  "qrPayload": "ysp:booking:88123:HMAC-sig",
  "validFrom": "2026-05-21T12:35:00",
  "validTo":   "2026-05-21T14:35:00"
}
```

**Notes**
- The mobile app doesn't have a payment SDK wired yet — decide on **Razorpay vs. Stripe vs. PhonePe** before this is implemented. Currently the design points to Razorpay (largest India coverage).
- Pay-later still needs `validTo` for the gate scanner.

---

### 4.9 Parking — Payment Capture Webhook (server-side)

Not consumed by the mobile, but mobile needs **one polling endpoint** so it can flip from `AWAITING_PAYMENT` → `CONFIRMED` after the payment sheet returns.

```
GET /api/v1/parking/bookings/{bookingId}
```

**Response** — same shape as §4.8 but with updated `status` ∈ `{AWAITING_PAYMENT, CONFIRMED, EXPIRED, CANCELLED, USED}`.

Better: push the status update via the existing WebSocket (`topic: "booking.status"`).

---

### 4.10 Resident — EV Charging Availability

**UI:** `residential_screen.dart` → `_buildEvCharging` (currently hardcoded "2 slots available, 50m away, 2-4 hours")

**Proposed endpoint**
```
GET /api/v1/me/ev-charging/nearest
```

**Response**
```json
{
  "stationId": 77,
  "name": "Phoenix Heights — Block B EV",
  "distanceMeters": 50,
  "availableSlots": 2,
  "totalSlots": 4,
  "estimatedWaitMins": null,
  "chargingTimeRange": { "minMins": 120, "maxMins": 240 }
}
```

If a "View All" surface is added later: `GET /api/v1/ev-charging/stations?lat&lng&radiusKm`.

---

### 4.11 Services — Quick Services / Bill Payments

**UI:** `features/services/screens/quick_services_screen.dart`
**Currently mocked at:** `features/services/data/services_repository.dart` → `getServicesData()`

The bill-payment integrations themselves (BBPS) are a major scope. Two pragmatic options:

1. **Defer entirely** — keep static tiles, mark P2.
2. **Aggregator passthrough** — proxy to BBPS / Setu / Razorpay BBPS sandbox.

If option 2 is chosen, propose this minimal contract:

```
GET  /api/v1/services/catalog
POST /api/v1/services/bill-fetch     // operator + consumerNumber → bill
POST /api/v1/services/bill-pay       // billRefId + paymentMode  → transaction
GET  /api/v1/me/transactions?page=&size=
```

**Recent Transactions response** (drives the "Recent Transactions" block):
```json
{
  "content": [
    {
      "transactionId": "tx_01HX...",
      "title": "Mobile Recharge",
      "subtitle": "+91 98765xxxxx",
      "amountPaise": 19900,
      "status": "SUCCESS",
      "completedAt": "2026-05-19T18:42:00"
    }
  ]
}
```

**Recommendation:** keep tiles static for V1; only ship `/me/transactions` so the screen is half-real. Bill-pay onboarding is multi-quarter.

---

### 4.12 Admin — Requests (Join / Vehicle Addition Approvals)

**UI:** `features/admin/requests/screens/requests_screen.dart`
**Currently mocked at:** `admin_repository.getRequestsData()`

**Fields per row:**
- `userName`, `unit`, `requestType` (`JOIN_REQUEST | VEHICLE_ADDITION | VISITOR | OTHER`), `timestamp`
- Action buttons: Approve / Reject

**Proposed endpoints**
```
GET  /api/v1/admin/requests?status=PENDING&page=0&size=20
POST /api/v1/admin/requests/{id}/approve
POST /api/v1/admin/requests/{id}/reject   // body: { "reason": "..." }
```

**Response**
```json
{
  "content": [
    {
      "requestId": 901,
      "type": "JOIN_REQUEST",
      "status": "PENDING",
      "requesterName": "John Doe",
      "requesterMobile": "+91...",
      "unitLabel": "Unit B-1506",
      "payload": { "fullname": "John Doe", "email": "..." },
      "createdAt": "2026-05-21T09:12:00"
    }
  ]
}
```

**Notes**
- `payload` is a discriminated-union shape — schema depends on `type`. Server decides what to commit on approve (create tenant, attach vehicle, etc.).
- Should emit a WebSocket event `topic: "admin.requests.new"` so the badge count updates in real time.

---

### 4.13 Admin — Security / Cameras

**UI:** `features/admin/security/screens/security_screen.dart`
**Currently mocked at:** `admin_repository.getSecurityData()`

**Fields displayed:**
- Aggregates: `activeCameras` ("24/28"), `securityAlerts` (count), `recordingHours`, `storageUsed` (% int), `incidents` (count), `systemStatus` (`SECURE | DEGRADED | OFFLINE`)
- Per-camera row: `zone`, `location`, `isActive`

**Proposed endpoints**
```
GET /api/v1/admin/security/summary
GET /api/v1/admin/security/cameras?page=&size=
```

**Summary response**
```json
{
  "cameras":      { "active": 24, "total": 28 },
  "alertsLast24h": 3,
  "recordingHours": 168,
  "storageUsedPct": 85,
  "incidentsLast30d": 12,
  "systemStatus": "SECURE"
}
```

**Camera response**
```json
{
  "content": [
    { "cameraId": 1, "zone": "Zone A - Entry Gate", "location": "Main Entrance", "isActive": true, "rtspProxyUrl": "https://..." }
  ]
}
```

**Notes**
- This is **P2** — many sites don't have NVR integrations. Spec it but don't block launch.
- `rtspProxyUrl` only needed when we add the live-view screen.

---

### 4.14 Auth — Profile Update

**Current bug:** `EditProfileScreen` calls `AuthController.updateUser` which only mutates local state and writes to `flutter_secure_storage`. **The change is lost on server-side and on re-login.** See `auth_controller.dart:91`.

**Proposed endpoint**
```
PUT /api/v1/me
```

**Request**
```json
{
  "fullname": "Mahesh Pujala",
  "email": "mahesh@example.com",
  "phone": "+919999999999"
}
```

**Response** — fresh `AppUser` payload (same shape as `/auth/authenticate` minus the token).

**Notes**
- The mobile call site needs a corresponding change (replace local copyWith with a `Dio.put`).
- Username changes are out of scope (treat as immutable).

---

### 4.15 Auth — Forgot Password (true reset)

**Current state:** the "Forgot Password" link routes to a screen that calls `POST /auth/change-password`, which only works for an **already-authenticated** user. The unauthenticated flow doesn't exist.

**Proposed endpoints**
```
POST /api/v1/auth/forgot-password         // body: { "identifier": "email-or-username" }
POST /api/v1/auth/forgot-password/verify  // body: { "identifier": "...", "otp": "123456" }
POST /api/v1/auth/forgot-password/reset   // body: { "resetToken": "...", "newPassword": "..." }
```

- Step 1 sends an OTP via email/SMS, returns `{ "challengeId": "...", "channel": "EMAIL", "maskedTarget": "ra***@example.com" }`.
- Step 2 returns `{ "resetToken": "...", "expiresAt": "..." }` on success.
- Step 3 invalidates the token and returns 204.

**Notes**
- Mobile screens need to be added (currently single-screen). Backend can ship endpoints first.

---

### 4.16 Notifications

**UI:** Bell icon in `find_your_spot_screen.dart` (top-right); no dedicated screen yet.

**Proposed endpoints**
```
GET  /api/v1/me/notifications?unread=true&page=0&size=20
POST /api/v1/me/notifications/{id}/read
POST /api/v1/me/notifications/mark-all-read
```

**Response item**
```json
{
  "notificationId": 4471,
  "type": "BOOKING_CONFIRMED",
  "title": "Booking confirmed",
  "body": "Your spot at GVK One Mall is reserved 12:30–14:30.",
  "deepLink": "ysp://bookings/88123",
  "read": false,
  "createdAt": "2026-05-21T12:35:00"
}
```

**Notes**
- Mobile already depends on `flutter_local_notifications`. Need FCM token registration:
  ```
  POST /api/v1/me/devices
  { "fcmToken": "...", "platform": "ANDROID|IOS", "appVersion": "1.0.0" }
  ```

---

## 5. Data Model Additions (server-side)

| Entity | Purpose | Key fields |
|---|---|---|
| `parking_spot` | Public parking inventory (§4.5–4.6) | id, name, address, lat, lng, total_slots, hourly_rate_paise, base_fee_paise, opening_hours, amenities[] |
| `parking_quote` | Short-lived price quote (§4.7) | id, spot_id, user_id, total_paise, expires_at |
| `parking_booking` | Customer reservation (§4.8) | id, quote_id, user_id, vehicle_number, status, payment_mode, payment_ref, valid_from, valid_to, qr_payload |
| `payment_transaction` | Audit of money movements | id, booking_id, provider, provider_order_id, amount_paise, status, captured_at |
| `ev_station` | EV charging inventory (§4.10) | id, society_id, name, total_slots, lat, lng |
| `admin_request` | Pending approvals (§4.12) | id, type, status, payload(jsonb), created_by, created_at, decided_by, decided_at |
| `security_camera` | NVR camera registry (§4.13) | id, society_id, zone, location, is_active, rtsp_url |
| `user_notification` | Per-user inbox (§4.16) | id, user_id, type, title, body, deep_link, read, created_at |
| `device_registration` | FCM tokens (§4.16) | id, user_id, fcm_token, platform, last_seen_at |

---

## 6. Suggested Delivery Order

This is the order the mobile team can integrate against without blocking on each other.

**Sprint 1 (P0 blockers)**
- §4.1 `GET /me/residence` — unblocks Residential screen
- §4.2 `GET /me/vehicles` — unblocks My Vehicles
- §4.14 `PUT /me` — fix silent-no-op bug
- §4.5–4.6 Parking spots list + detail
- §4.12 Admin Requests

**Sprint 2 (P0 booking flow)**
- §4.7 Quote
- §4.8 Booking
- §4.9 Booking status (WebSocket recommended)
- §4.4 Visitor pass

**Sprint 3 (P1)**
- §4.3 Smart access card
- §4.10 EV charging
- §4.16 Notifications + FCM registration
- §4.15 Forgot password

**Backlog (P2)**
- §4.11 Quick Services / bill pay
- §4.13 Security / cameras

---

## 7. Open Questions for Backend

1. **Payment provider** — Razorpay vs. PhonePe vs. Stripe? Affects §4.8 contract.
2. **Multi-society scoping** — when a single login owns units in two societies, do we need a `society` selector at login? Affects §4.1.
3. **Visitor pass revocation** — should we expose `DELETE /me/visitor-passes/{id}`? Not in scope above.
4. **QR signing scheme** — HMAC-SHA256 with a per-society rotating secret? Needs a separate threat-model doc.
5. **Pagination shape** — confirm `content[]` (current admin endpoints use this); align all new endpoints.
6. **BBPS** — is bill-pay in scope for V1? If no, freeze §4.11 to static tiles.
7. **Tenant context headers** — keep `subdomain` + `customerCode` as headers, or fold them into the JWT? The latter would simplify mobile.

---

## 8. Mobile-side TODOs (visibility for backend)

These do not block backend work but are tracked here so both sides see the full picture:

- Replace `ResidentialRepository.getResidentialData()` mock with real wiring once §4.1–4.2 ship.
- Add Razorpay SDK (or chosen provider) and a checkout screen between §4.8 response and §4.9.
- Build a Notifications screen + bell-icon badge once §4.16 ships.
- Convert `EditProfileScreen` to call §4.14 instead of mutating local state.
- Add a true forgot-password flow (3 screens) for §4.15.
- Promote tenant context out of hardcoded constants — `--dart-define` per build flavor.
