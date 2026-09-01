# 🏙️ YellowSpot — Smart Residential Operating System & Society Operations Center

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2.svg?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod-8A2BE2.svg)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-00C853.svg)](#architecture)
[![Tests](https://img.shields.io/badge/Tests-39%20Passed-brightgreen.svg)](#testing)
[![Web Build](https://img.shields.io/badge/Web%20Build-Verified-success.svg)](#build--deployment)

**YellowSpot** is a next-generation **Smart Residential Operating System** and **Society Operations Center** designed for gated communities, modern residential towers, and smart township ecosystems.

---

## 📐 Architecture & System Topology

```text
                    YELLOWSPOT OS
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       RESIDENT        ADMIN         SECURITY
          │              │              │
          └──────────────┼──────────────┘
                         │
                    BACKEND API
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
    PARKING            ACCESS           SERVICES
       │                 │                 │
   AI Vision          RFID/NFC          Vendors
       │                 │
     ANPR             Gates
       │                 │
       └───────────────┬─┘
                       │
                    WEBSOCKET
                       │
                  REAL-TIME OS
```

---

## ✨ Key Feature Modules

### 1. 👤 Resident Experience
* **Home Dashboard**: Society highlights, primary vehicle status, one-tap quick actions, and live activity timeline.
* **Parking Hub**: Real-time slot discovery across basement levels, bay filtering (EV, 4W, 2W), map visualization, and digital QR parking passes with concurrency conflict resolution (409 Conflict).
* **Residence Hub**:
  * 👥 **Visitor Management**: Pre-approved digital guest passes, cab tracking, and arrival push notifications.
  * 📦 **Deliveries & Gate Parcels**: Package tracking with security desk hold/release states.
  * 🧹 **Domestic Staff Directory**: Attendance tracking and gate entry/exit logging.
  * 🏊 **Amenities Booking**: Facility reservations (Clubhouse, Swimming Pool, Tennis Court, Banquet).
  * 🛠️ **Maintenance Requests**: Service ticket submission with SLA status tracking.
  * 📢 **Community Feed**: Official notices, resident discussions, and polls.
  * 🎫 **Digital Access Pass**: Dynamic QR access badge with offline fallback.
* **Vehicle Garage**: Multi-vehicle registry with FastTag RFID tag linkage and designated parking bay allocations.
* **Services Hub & EV Charging**: Doorstep car wash, tire care, periodic maintenance, and live EV charging station telemetry (OCPP ready).
* **YellowSpot Wallet**: Society maintenance dues, parking top-ups, and auto-pay ledgers.
* **Emergency SOS**: Multi-service emergency trigger (Medical, Fire, Security, Lift Alarm) with anti-accidental click safeguard.
* **AI Assistant**: Natural language dispatcher with permission-checked tool routing.

---

### 2. 🏛️ Society Admin & Security Operations Center
* **Live Operations Dashboard**: Resident metrics, vehicle counts, occupancy statistics, and pending approvals.
* **Resident Directory**: Filterable directory by Owners/Tenants with multi-unit management.
* **Vehicle & Bay Registry**: Society-wide vehicle database linked to allocated parking slots and RFID tags.
* **Smart Cards & RFID Lifecycle**: Software state transitions (`ACTIVE`, `SUSPENDED`, `REVOKED`) and gate permission sets.
* **Security & SOS Command Center**: Live emergency alerts with responder assignment and resolution logging.
* **Gate Device Telemetry**: Real-time status for ANPR cameras, RFID FastTag readers, and boom barriers with manual override triggers.
* **Operational Audit Logs**: Immutable trail capturing Operator, Role, Action, Target, Timestamp, and Result.

---

## 🔐 Role-Based Access Control (RBAC)

The application enforces a **6-tier operational permission matrix**:

| Role | Resident Directory | Vehicle Registry | Parking Allocation | Smart Cards (RFID) | Gate Barrier Control | SOS Responder | Maintenance | Audit Logs |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Super Admin** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Society Admin** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Security Manager** | ❌ Read | ✅ Full | ❌ Read | ✅ Full | ✅ Full | ✅ Full | ❌ Read | ❌ Read |
| **Security Guard** | ❌ No | ❌ Read | ❌ Read | ❌ Read | ✅ Override | ✅ Respond | ❌ No | ❌ No |
| **Facility Manager** | ❌ No | ❌ No | ✅ Full | ❌ No | ❌ No | ❌ No | ✅ Full | ❌ No |
| **Maintenance Manager** | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No | ✅ Full | ❌ No |

---

## 🌍 Environment & Demo Configuration

YellowSpot supports three explicit environments configured in `lib/core/config/app_config.dart`:

| Environment | Base API URL | WebSocket URL | Mock Fallback | Visual Watermark |
| :--- | :--- | :--- | :---: | :---: |
| **Development** | `http://localhost:8080/api/v1` | `ws://localhost:8080/ws` | ✅ Enabled | `⚡ DEMO DATA (SIMULATION)` |
| **Staging** | `https://staging-api.yellowspot.io/api/v1` | `wss://staging-api.yellowspot.io/ws` | ✅ Enabled | `⚠️ STAGING ENVIRONMENT` |
| **Production** | `https://api.yellowspot.io/api/v1` | `wss://api.yellowspot.io/ws` | ❌ Disabled | None (Live Clean UI) |

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── config/             # AppConfig, Environment Strategy & FeatureFlags
│   ├── constants/          # ApiEndpoints, Asset Paths & Global Constants
│   ├── providers/          # Global Riverpod State Providers
│   ├── services/
│   │   ├── logging/        # PII-Safe LoggerService
│   │   ├── network/        # DioInterceptor, WebSocketService & ApiErrorHandler
│   │   └── notifications/  # Local & Push Notification Service
│   ├── theme/              # Design System Tokens, AppColors, TextStyles & Theme
│   └── widgets/            # Reusable UI Widgets (Cards, Status Pills, Buttons, Banners)
├── features/
│   ├── admin/              # Society Admin Operations Center & Security Dashboard
│   ├── ai_assistant/       # Permission-Guarded AI Tool Calling Dispatcher
│   ├── auth/               # JWT Authentication, Session Restore & Role Switcher
│   ├── emergency/          # SOS Command Center & Emergency Dispatch
│   ├── ev_charging/        # EV Station Discovery & Session Monitor
│   ├── home/               # Resident Home Dashboard & Highlights
│   ├── notifications/      # Notification Center with Category Filters
│   ├── parking/            # Smart Parking Hub, Discovery & QR Passes
│   ├── residence/          # Visitors, Staff, Deliveries, Amenities & Maintenance
│   ├── services/           # Doorstep Vehicle Services & Status Tracking
│   ├── vehicles/           # My Garage Multi-Vehicle Registry
│   └── wallet/             # YellowSpot Wallet & Society Maintenance Dues
└── main.dart               # Application Entrypoint
```

---

## 🧪 Testing & Validation Suite

YellowSpot includes **39 automated unit, widget, and end-to-end integration tests**:

```bash
# Run all automated tests
flutter test

# Run static analysis
flutter analyze

# Build Web distribution
flutter build web
```

### Verified Test Categories:
* ✅ **Multi-Tenant Isolation**: Verified that Resident A (Unit A-101) querying Unit A-102 returns `403 Forbidden`.
* ✅ **Concurrency Race Conditions**: Verified that simultaneous slot bookings authoritatively throw `409 Conflict`.
* ✅ **Security & Authorization Penetration**: Verified that unauthorized mutations, expired JWTs, and replayed QR passes are rejected.
* ✅ **Admin RBAC Matrix**: Validated all 6 administrative sub-roles.
* ✅ **End-to-End User Workflows**: Validated Resident Home -> Parking Hub -> Active Pass -> Visitor Pass flows.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK `^3.47.2`
* Dart SDK `^3.8.1`

### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/maheshpujala-ys/ys_userapp.git
cd ys_userapp

# 2. Install dependencies
flutter pub get

# 3. Launch the application
flutter run
```

---

## 📄 License & Confidentiality
Copyright © 2026 **Yellowspot Technologies Pvt Ltd**. All rights reserved.
