# YellowSpot Smart Residential OS — Backend API Contract & Integration Specification

This document defines the formal REST API endpoints, WebSocket event streams, authentication requirements, and hardware integration contracts for the **YellowSpot Smart Residential Operating System**.

---

## 1. Environment Topology & Base URLs

| Environment | Base API URL | WebSocket URL | Mock Fallback | Demo Indicator |
| :--- | :--- | :--- | :---: | :---: |
| **Development** | `http://localhost:8080/api/v1` | `ws://localhost:8080/ws` | ✅ Enabled | `DEMO DATA` |
| **Staging** | `https://staging-api.yellowspot.io/api/v1` | `wss://staging-api.yellowspot.io/ws` | ✅ Enabled | `STAGING` |
| **Production** | `https://api.yellowspot.io/api/v1` | `wss://api.yellowspot.io/ws` | ❌ Disabled | None (Live) |

---

## 2. API Contract Inventory

### 2.1 Authentication & Session
* **`POST /auth/login`**
  * **Auth**: None
  * **Request**: `{"email": "user@test.com", "password": "password"}`
  * **Response**: `{"token": "jwt_token", "user": {"id": "u-1", "email": "...", "name": "...", "roles": ["user"], "societyId": "soc-1", "unit": "A-1204"}}`
  * **Status**: `REAL BACKEND READY` (Supports JWT Bearer token authentication)
* **`POST /auth/logout`**
  * **Auth**: `Bearer <token>`
  * **Response**: `{"success": true}`
* **`GET /auth/me`**
  * **Auth**: `Bearer <token>`
  * **Response**: Current user profile and permission set.

---

### 2.2 Parking Hub (P0 Integration)
* **`GET /parking/spots?societyId={id}`**
  * **Auth**: `Bearer <token>`
  * **Response**: `[{"id": "B2-45", "floor": "B2", "bay": "45", "type": "EV", "isOccupied": false, "isReserved": true}]`
  * **Status**: `API CONTRACT DEFINED`
* **`POST /parking/book`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"spotId": "B2-45", "vehicleId": "v-1", "startTime": "2026-09-01T10:00:00Z", "durationMinutes": 120}`
  * **Response**: `{"bookingId": "bk-994", "status": "CONFIRMED", "qrCode": "QR_PASS_TOKEN_994", "expiresAt": "..."}`
  * **Error 409 Conflict**: Returned when another user concurrently books the same slot.
* **`POST /parking/bookings/cancel`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"bookingId": "bk-994"}`

---

### 2.3 Access Control, ANPR & Gate Telemetry
* **`GET /gates/telemetry`**
  * **Auth**: `Bearer <token>` (Admin/Security)
  * **Response**: `[{"gateId": "gate-1", "name": "Main Gate", "anprCamera": "ONLINE", "rfidReader": "ONLINE", "barrier": "ONLINE", "isBarrierOpen": false}]`
  * **Status**: `HARDWARE INTEGRATION REQUIRED` (OCPP / IoT Controller hook)
* **`POST /gates/override`**
  * **Auth**: `Bearer <token>` (Admin/Security Guard)
  * **Request**: `{"gateId": "gate-1", "command": "OPEN_BARRIER", "reason": "VIP Guest Arrival"}`
  * **Response**: `{"success": true, "auditLogId": "aud-102"}`

---

### 2.4 Visitor Management
* **`POST /residence/visitors/invite`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"name": "Rahul Sharma", "phone": "+91 98765 43210", "expectedArrival": "2026-09-01T16:00:00Z", "vehicleNumber": "TS 09 AB 1234"}`
  * **Response**: `{"passId": "vp-881", "passCode": "GUEST-881", "qrToken": "...", "status": "EXPECTED"}`
  * **Status**: `API CONTRACT DEFINED`
* **`GET /residence/visitors`**
  * **Auth**: `Bearer <token>`
  * **Response**: List of active/historical visitor passes with statuses: `EXPECTED`, `ARRIVED`, `INSIDE`, `EXITED`, `EXPIRED`.

---

### 2.5 Emergency & SOS Command Center
* **`POST /emergency/dispatch`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"emergencyType": "MEDICAL", "location": "Tower A Floor 12", "coordinates": {"lat": 17.44, "lng": 78.38}}`
  * **Response**: `{"alertId": "sos-441", "status": "DISPATCHED", "dispatchedAt": "...", "commandCenterNotified": true}`
  * **Status**: `API CONTRACT DEFINED`
* **`POST /emergency/resolve`**
  * **Auth**: `Bearer <token>` (Security / Admin)
  * **Request**: `{"alertId": "sos-441", "note": "Resolved by Security Patrol"}`

---

### 2.6 EV Charging Bays
* **`POST /ev/sessions/start`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"chargerId": "CHG-BAY-B2-45", "vehicleId": "v-1"}`
  * **Response**: `{"sessionId": "ev-sess-12", "status": "CHARGING", "initialKwh": 0.0}`
  * **Status**: `OCPP / CHARGER HARDWARE REQUIRED`
* **`POST /ev/sessions/stop`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"sessionId": "ev-sess-12"}`
  * **Response**: `{"sessionId": "ev-sess-12", "status": "COMPLETED", "energyConsumedKwh": 14.8, "cost": 222.0}`

---

### 2.7 Wallet & Payments
* **`GET /wallet/balance`**
  * **Auth**: `Bearer <token>`
  * **Response**: `{"balance": 2450.0, "currency": "INR", "autoRechargeEnabled": true}`
  * **Status**: `PAYMENT GATEWAY / LEDGER REQUIRED`
* **`POST /wallet/topup`**
  * **Auth**: `Bearer <token>`
  * **Request**: `{"amount": 1000.0, "paymentGateway": "RAZORPAY", "orderId": "order_Hj89K..."}`

---

### 2.8 WebSocket Real-Time Event Stream
* **URL**: `wss://api.yellowspot.io/ws?token=<jwt_token>`
* **Simulated & Live Event Types**:
  * `PARKING_OCCUPANCY_CHANGED`: `{"type": "PARKING_OCCUPANCY_CHANGED", "data": {"bay": "B2-45", "isOccupied": true}}`
  * `GATE_ACCESS_EVENT`: `{"type": "GATE_ACCESS_EVENT", "data": {"gate": "Main Gate", "vehicle": "TS 09 EQ 4821", "result": "AUTHORIZED"}}`
  * `SOS_ALERT_TRIGGERED`: `{"type": "SOS_ALERT_TRIGGERED", "data": {"alertId": "sos-1", "resident": "...", "type": "MEDICAL"}}`
  * `VISITOR_ARRIVED`: `{"type": "VISITOR_ARRIVED", "data": {"passId": "vp-881", "visitorName": "..."}}`

---

## 3. Production Readiness & Dependency Classification

| Subsystem | Architectural Status | External Dependency |
| :--- | :--- | :--- |
| **Authentication** | `REAL BACKEND READY` | YellowSpot User Identity Service |
| **Multi-Tenant Isolation** | `ENFORCED ON CLIENT & CONTRACT` | Backend DB Tenant Filter (`societyId`, `unitId`) |
| **Parking Discovery & Booking** | `CONTRACT DEFINED` | Parking Allocation Backend Engine |
| **ANPR Camera Recognition** | `HARDWARE REQUIRED` | CCTV Camera RTSP Feed + ANPR AI Server |
| **Gate Boom Barriers** | `HARDWARE REQUIRED` | IoT Controller / Relays at Physical Gates |
| **RFID / FastTag Readers** | `HARDWARE REQUIRED` | UHF RFID Gate Readers |
| **EV Charging Stations** | `HARDWARE REQUIRED` | OCPP 1.6 / 2.0.1 Central System |
| **Wallet & UPI Payments** | `PAYMENT GATEWAY REQUIRED` | Razorpay / Stripe / Bank UPI Webhooks |
| **Emergency SOS** | `BACKEND READY` | Central Command Dispatch Engine & SMS/Twilio Gateway |
| **AI Assistant** | `SAFE DISPATCHER READY` | YellowSpot LLM Tool Calling Endpoint |
