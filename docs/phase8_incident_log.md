# 📝 YellowSpot Phase 8 — Physical Commissioning Incident Log

This document tracks all physical gate commissioning, hardware interfacing, network edge, and sensor telemetry incidents encountered during Phase 8 field testing, including root causes, mitigation steps, retest logs, and current status.

---

## Incident Summary

| Incident ID | Subsystem | Severity | Description | Status |
| :--- | :--- | :--- | :--- | :--- |
| **INC-P8-001** | Boom Barrier Feedback | High | Inductive limit switch bouncing causing momentary `FAULT` state during rapid deceleration | **RESOLVED** |
| **INC-P8-002** | ANPR Camera | Medium | License plate reflection under direct late-afternoon sunlight reducing OCR confidence to 58% | **RESOLVED** |
| **INC-P8-003** | Gate Controller | High | Modbus TCP socket timeout under concurrent ANPR query and manual guard override | **RESOLVED** |
| **INC-P8-004** | Edge Gateway NTP | Critical | 3.2-second clock drift between on-prem edge gateway and cloud backend disrupting event sequencing | **RESOLVED** |
| **INC-P8-005** | Safety Photocell | Critical | Safety optical beam sensor wired as Normally Closed (NC) instead of Normally Open (NO), inverting obstruction signal | **RESOLVED** |

---

## Detailed Incident Records

### Incident: INC-P8-001
* **Date / Time:** 2026-09-02 06:45:12 IST
* **Subsystem:** Magnetic AutoControl Boom Barrier & Advantech ADAM-6060 Controller
* **Description:** During test cycle #14 (rapid vehicle entry), the physical boom reached full vertical limit, but mechanical vibration caused the digital limit switch contact to bounce, emitting a transient `0 -> 1 -> 0` signal. The gate controller registered this as an abnormal `FAULT` state before settling to `OPEN`.
* **Impact:** False positive hardware alarm dispatched to Admin Console; entry event delayed by 850ms.
* **Root Cause:** Digital input debounce filter on the ADAM-6060 controller was set to default 5ms, which was insufficient to dampen mechanical micro-bounce on the limit switch.
* **Mitigation / Fix:** Configured hardware input debounce filter to 35ms on digital input channel DI-01 and DI-02 via controller firmware config.
* **Retest Result:** 50 consecutive barrier cycles executed. 0 bounce errors. Logical state transitions smoothly from `OPENING` to `OPEN`.
* **Status:** `RESOLVED` (Verified by Lead Gate Engineer).

---

### Incident: INC-P8-002
* **Date / Time:** 2026-09-02 07:12:30 IST
* **Subsystem:** Hikvision ANPR Camera (iDS-2CD7A26G0/P-IZHS)
* **Description:** Test vehicle `KA-03-MN-8821` approached Gate 1 lane during direct sun glare angle (16:30 equivalent simulated light angle). Plate OCR confidence dropped to 58%, triggering `NO_MATCH` and requiring manual guard verification.
* **Impact:** Automated entry failed for a valid registered resident; lane throughput dropped.
* **Root Cause:** Wide Dynamic Range (WDR) and anti-glare polarization filter on camera lens were set to indoor/standard preset instead of high-contrast vehicular traffic preset.
* **Mitigation / Fix:** Adjusted WDR level to 120dB, enabled license plate ROI auto-gain compensation, and installed a 15-degree glare shield hood on the overhead mount.
* **Retest Result:** 20 vehicle approaches under direct glare tested. Recognition rate improved to 97.4% (>90% confidence score).
* **Status:** `RESOLVED`.

---

### Incident: INC-P8-003
* **Date / Time:** 2026-09-02 07:55:04 IST
* **Subsystem:** Edge Gateway & Moxa ioLogik Controller
* **Description:** When a manual guard override pulse (`POST /gates/override`) arrived simultaneously with an automated ANPR vehicle open trigger, the controller Modbus TCP daemon threw a connection reset (`ECONNRESET`).
* **Impact:** Barrier command stalled for 2.4 seconds until connection timeout retry succeeded.
* **Root Cause:** The edge daemon was opening a new ephemeral Modbus TCP connection for every command rather than utilizing a persistent connection pool with serialized command queueing.
* **Mitigation / Fix:** Refactored edge controller driver to maintain a single persistent Modbus TCP connection with mutex-guarded FIFO command queueing.
* **Retest Result:** Concurrent load of 10 automated and manual commands executed simultaneously. All 10 commands serialized and acknowledged in <80ms without socket drops.
* **Status:** `RESOLVED`.

---

### Incident: INC-P8-004
* **Date / Time:** 2026-09-02 08:30:19 IST
* **Subsystem:** Edge Gateway & Cloud Backend Event Stream
* **Description:** Entry events generated at the edge gateway appeared with timestamps 3.2 seconds ahead of the cloud database time. In the resident timeline, the entry notification appeared with a timestamp in the "future".
* **Impact:** Broken chronological ordering in security audit logs and resident event timeline.
* **Root Cause:** Edge gateway local RTC had not synchronized with NTP upstream due to local firewall blocking UDP port 123 to public pool servers.
* **Mitigation / Fix:** Added local NTP firewall rule allowing access to `time.google.com` and configured chrony daemon on Edge Gateway to synchronize every 60 seconds with hardware clock discipline.
* **Retest Result:** Measured clock drift across ANPR camera, RFID reader, Edge Gateway, and Cloud Backend reduced to < 4ms.
* **Status:** `RESOLVED`.

---

### Incident: INC-P8-005
* **Date / Time:** 2026-09-02 09:10:45 IST
* **Subsystem:** Safety Photocell Sensors & Magnetic Access Pro-L
* **Description:** During safety barrier testing, placing a physical test obstacle in the barrier path while open caused the controller to think the lane was obstructed, but breaking the beam while closing failed to trigger auto-rebound.
* **Impact:** Critical life-safety hazard — barrier arm would not auto-reverse if a vehicle or pedestrian crossed during descent.
* **Root Cause:** Wiring discrepancy on terminal block TB-3: safety sensor output was wired to Normally Closed (NC) pin with inverted logic in the barrier logic board.
* **Mitigation / Fix:** Rewired photocell relay to Normally Open (NO) fail-safe terminal and verified hardware jumper configuration on barrier main board per Magnetic AutoControl installation manual Section 4.3.
* **Retest Result:** Tested with physical dummy obstacle across 30 closing cycles. 100% of obstructions immediately halted descent in <80ms and auto-rebounded to `FULL_OPEN`.
* **Status:** `RESOLVED` (Life-Safety Signoff Approved).
