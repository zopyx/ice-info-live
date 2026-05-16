# ICE Info Live — iOS Reimplementation Requirements

## 1. Overview

ICE Info Live is an unofficial companion app for passengers on Deutsche Bahn ICE trains. It reads live data from the onboard ICE Portal API (available via the train's "WIFIonICE" Wi-Fi) and presents it in a modern, user-friendly interface.

**Target Platform:** iOS 17.0+ (iPhone primary; iPad adaptive layout desirable)  
**Language:** Swift  
**UI Framework:** SwiftUI  
**Architecture:** MVVM with async/await and `@Observable` / `ObservableObject`

---

## 2. Functional Requirements

### 2.1 Core Data Display (FR-001 … FR-009)

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | **Live Train Status** — Display real-time speed (km/h), train number/type (e.g., ICE 123), wagon class (1st/2nd), and next stop name. | P0 |
| FR-002 | **Route Timeline** — Show a vertical, scrollable timeline of all stops on the trip with passed/current/upcoming states, scheduled/actual arrival & departure times, platform/track info, delays, and cancellation indicators. | P0 |
| FR-003 | **Map View** — Display the train's current GPS position on a map with a position marker. Support standard map interactions (pan, zoom). | P0 |
| FR-004 | **Connections** — At the next or user-selected stop, show connecting trains with train type, number, destination, departure time, platform, delay, transfer time, and a reachability indicator (reachable / tight / missed). | P0 |
| FR-005 | **Departures Board** — Fetch and display additional departures at the target/next stop via the public `v6.db.transport.rest` API. Show line name, destination, scheduled time, delay, platform, and cancellation status. | P1 |
| FR-006 | **Points of Interest** — Display nearby landmarks (cities, monuments, mountains, rivers, lakes) fetched from the ICE Portal, with name, type, distance, and description. | P1 |
| FR-007 | **Delay Information** — Show delay badges (minutes) and delay reason cards when delays exist. | P0 |
| FR-008 | **Connectivity Status** — Display current and upcoming Wi-Fi / mobile connectivity state on the train with visual quality indicators (strong / weak / no connection). | P1 |
| FR-009 | **Target Stop Selection** — Allow the user to select a personal destination from upcoming stops. All summary cards (ETA, progress, connections) should reflect the selected target. | P0 |

### 2.2 Navigation & Screens (FR-010 … FR-014)

| ID | Requirement | Priority |
|---|---|---|
| FR-010 | **Tab Bar Navigation** — Five primary tabs: **Status**, **Stops** (Halte), **Map** (Karte), **Service**, **Connections** (Anschlüsse). | P0 |
| FR-011 | **Home / Status Screen** — Show train header (animated or static), target stop selector, travel summary (distance, progress, ETA, delay), connectivity row, and demo speed slider when in mock mode. | P0 |
| FR-012 | **Service Screen** — Placeholder / WIP screen for future service information. | P2 |
| FR-013 | **Settings** — Accessible from the top bar, presented as a sheet. Must include: theme (Light / Dark / System), language (German / English), reduced motion toggle, crash reporting opt-in, debug mode toggle. | P1 |
| FR-014 | **Info & About** — Dialog/sheet showing app version, privacy policy, legal notices, API attribution, and changelog. | P1 |

### 2.3 Offline & Demo Mode (FR-015 … FR-017)

| ID | Requirement | Priority |
|---|---|---|
| FR-015 | **Wi-Fi Detection** — Detect whether the device is connected to the "WIFIonICE" SSID. If not, show an offline state with retry and demo mode entry. | P0 |
| FR-016 | **Demo Mode** — Fully offline mode using bundled mock data. Must support an adjustable speed slider (0–300 km/h) and make all screens functional with mock data. | P0 |
| FR-017 | **No-Wifi Screen** — When not on WIFIonICE and not in demo mode, show a clear offline screen with retry and "Try Demo Mode" buttons. | P0 |

### 2.4 Notifications & Live Activities (FR-018 … FR-021)

| ID | Requirement | Priority |
|---|---|---|
| FR-018 | **Live Activity** — Show a Live Activity on the Lock Screen and in the Dynamic Island when the user enables tracking. Display train name, speed, next stop or target stop, distance remaining, estimated minutes, ETA, delay, and a progress bar toward the target. | P0 |
| FR-019 | **Live Activity Polling** — Poll the ICE Portal API every 5 seconds (with exponential backoff on failure: max 60s, max 4 steps) while the Live Activity is active. | P0 |
| FR-020 | **Push-to-Widget Update** — Live Activity and widget must update in near real-time as train data changes. | P1 |
| FR-021 | **Exit-Now Alert** — When approaching the selected target stop (within a configurable distance/time threshold), highlight an "Exit Now" or "Prepare to Exit" warning in the Live Activity and widget. | P1 |

### 2.5 Home Screen Widget (FR-022 … FR-024)

| ID | Requirement | Priority |
|---|---|---|
| FR-022 | **Widget (Small / Medium)** — Display train name, current speed, next stop, target stop, delay, and an "Exit Now" alert when approaching the target. | P1 |
| FR-023 | **Widget Refresh** — Update the widget whenever new train data is fetched (from the app or background refresh). | P1 |
| FR-024 | **App Group Sharing** — Use App Groups to share train state between the main app and the widget extension. | P1 |

### 2.6 Onboarding & User Preferences (FR-025 … FR-029)

| ID | Requirement | Priority |
|---|---|---|
| FR-025 | **Onboarding** — First-launch feature overview explaining what the app does and how to use it. | P1 |
| FR-026 | **Crash Reporting Consent** — Show an opt-in dialog for crash reporting (per-version; show once per app update). Default to disabled. | P1 |
| FR-027 | **Localization** — Full German and English support. German as default; English selectable in settings. Changing language requires an app restart. | P1 |
| FR-028 | **Reduced Motion** — Respect system accessibility settings; provide an override in settings. When enabled, disable train animation and screen transition animations. | P1 |
| FR-029 | **Theme** — Support Light, Dark, and System (follow iOS appearance) themes. | P1 |

### 2.7 Data & Networking (FR-030 … FR-036)

| ID | Requirement | Priority |
|---|---|---|
| FR-030 | **ICE Portal API Client** — Fetch from `https://iceportal.de/api1/rs/status` and `/api1/rs/tripInfo/trip`. Support HTTPS-first with automatic HTTP fallback. | P0 |
| FR-031 | **POI API** — Fetch from `/api1/rs/pois/map/{bbox}`. | P1 |
| FR-032 | **Connections API** — Fetch from `/api1/rs/tripInfo/connection/{evaNr}`. | P0 |
| FR-033 | **Departures API** — Fetch from `https://v6.db.transport.rest/stops/{evaNr}/departures`. | P1 |
| FR-034 | **Parallel Fetching** — Status and trip info should be fetched together and merged into a single domain model. | P0 |
| FR-035 | **Graceful Degradation** — On any network error, return empty/default data rather than crashing. Show appropriate UI states. | P0 |
| FR-036 | **Cleartext Support** — Allow cleartext HTTP for `iceportal.de` only (ATS exception). | P0 |

### 2.8 Debug & Diagnostics (FR-037 … FR-038)

| ID | Requirement | Priority |
|---|---|---|
| FR-037 | **Debug Mode** — In settings, enable a debug mode that shows raw API responses, allows copying them to clipboard, and sharing as a text file. | P2 |
| FR-038 | **Raw API Inspection** — Fetch and display raw JSON from the ICE Portal endpoints for troubleshooting. | P2 |

---

## 3. Non-Functional Requirements

### 3.1 Performance

| ID | Requirement |
|---|---|
| NFR-001 | UI must remain responsive while polling APIs every 3–5 seconds. |
| NFR-002 | Map rendering must not block the main thread. |
| NFR-003 | Initial app launch to interactive UI must be < 2 seconds on modern iPhones. |

### 3.2 Reliability

| ID | Requirement |
|---|---|
| NFR-004 | Network timeouts: ICE Portal = 5s request / 3s connect; transport.rest = 8s request / 4s connect. |
| NFR-005 | Exponential backoff for failed polling: start at 5s, max 60s, max 4 steps. |
| NFR-006 | App must handle malformed or partial API responses gracefully (`ignoreUnknownKeys` equivalent). |

### 3.3 Accessibility

| ID | Requirement |
|---|---|
| NFR-007 | Support Dynamic Type (preferred content size). |
| NFR-008 | Respect Reduce Motion system setting; provide in-app override. |
| NFR-009 | All images and icons must have accessibility labels. |
| NFR-010 | Support VoiceOver for all interactive elements. |

### 3.4 Privacy & Security

| ID | Requirement |
|---|---|
| NFR-011 | No authentication or personal data collection required. |
| NFR-012 | Crash reporting must be opt-in, not opt-out. |
| NFR-013 | No analytics or tracking without explicit user consent. |

### 3.5 Maintainability

| ID | Requirement |
|---|---|
| NFR-014 | Use Swift Concurrency (`async/await`) throughout; avoid completion handlers. |
| NFR-015 | Use structured concurrency (`TaskGroup`, `Actor`) for concurrent API calls. |
| NFR-016 | Separate networking, domain, and UI layers clearly. |

---

## 4. Data Models (Domain)

The following domain models must exist in the iOS codebase (Swift structs, `Codable` or `@Observable` where appropriate):

```swift
struct TrainStatus: Equatable {
    let trainType: String          // e.g., "ICE"
    let trainNumber: String        // e.g., "123"
    let tzn: String               // Train set number
    let speed: Int                // km/h
    let latitude: Double
    let longitude: Double
    let wagonClass: Int           // 1 or 2
    let connectivity: ConnectivityState
    let nextStop: TrainStop?
    let destination: Station
    let stops: [TrainStop]
    let delayMinutes: Int
    let delayReasons: [String]
    let targetStopEva: String?
    let isMockMode: Bool
}

struct TrainStop: Equatable, Identifiable {
    let id = UUID()
    let station: Station
    let timetable: Timetable
    let track: String?
    let passed: Bool
    let isCurrentStop: Bool
    let isNextStop: Bool
    let distanceFromStart: Int
    let delayMinutes: Int
    let cancelled: Bool
    let additionalStop: Bool
}

struct Station: Equatable {
    let name: String
    let evaNr: String
}

struct Timetable: Equatable {
    let scheduledArrival: Date?
    let actualArrival: Date?
    let scheduledDeparture: Date?
    let actualDeparture: Date?
}

struct PoiItem: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let distance: Int
    let latitude: Double
    let longitude: Double
    let description: String?
}

struct ConnectingTrain: Equatable, Identifiable {
    let id = UUID()
    let type: String
    let number: String
    let destination: String
    let departureTime: Date
    let track: String?
    let delayMinutes: Int
    let reachable: Bool
    let transferMinutes: Int
}

struct Departure: Equatable, Identifiable {
    let id = UUID()
    let lineName: String
    let destination: String
    let scheduledTime: Date
    let delayMinutes: Int
    let platform: String?
    let cancelled: Bool
}

enum ConnectivityState: Equatable {
    case strong
    case weak
    case noConnection
    case noInfo
}
```

---

## 5. API Specification

### 5.1 ICE Portal (On-Train Wi-Fi)

| Endpoint | Method | Description |
|---|---|---|
| `https://iceportal.de/api1/rs/status` | GET | Current speed, GPS, wagon class, connectivity, TZN |
| `https://iceportal.de/api1/rs/tripInfo/trip` | GET | Full trip with stops, timetable, tracks, delay reasons |
| `https://iceportal.de/api1/rs/pois/map/{lat1}/{lon1}/{lat2}/{lon2}` | GET | Nearby POIs |
| `https://iceportal.de/api1/rs/tripInfo/connection/{evaNr}` | GET | Connecting trains at a stop |

**Behavior:**
- Try HTTPS first. If the connection fails with a network error, fall back to HTTP.
- Some train firmware returns POIs as a JSON object, others as an array. Handle both.

### 5.2 transport.rest (Public API)

| Endpoint | Method | Description |
|---|---|---|
| `https://v6.db.transport.rest/stops/{evaNr}/departures?when={ISO8601}&duration={min}&results=30` | GET | Departure board for a station |

---

## 6. UI/UX Specification

### 6.1 Design System

- **Primary Color:** Deutsche Bahn Red `#EC0016`
- **Secondary Color:** DB Blue `#0076B6`
- **Background (Light):** `#F0F3F5`
- **Background (Dark):** `#131821`
- **Surface (Dark):** `#1E2433`
- **Typography:**
  - Headlines: Bold, rounded geometric sans-serif (SF Rounded or custom font like Space Grotesk)
  - Body: System font (SF Pro) or Inter

### 6.2 Key UI Components

1. **Train Header** — Large speed display with train illustration. On iOS, use a SwiftUI `Canvas` or `Image` with offset animation for track parallax (respect Reduce Motion).
2. **Floating Bottom Bar** — Custom pill-shaped tab bar centered at the bottom, not the standard iOS `TabView` if seeking visual parity. Alternatively, use a styled `TabView` for native feel.
3. **App Card** — Rounded rectangle (`cornerRadius: 20`), subtle shadow, 0.75pt outline border.
4. **Timeline Stop Row** — Vertical line with dots; passed stops are dimmed, current stop is highlighted.
5. **Delay Badge** — Small pill with red background showing `+N` minutes.
6. **Travel Summary Card** — Progress bar (custom wavy or standard `ProgressView`) showing journey completion toward the target stop.
7. **Connectivity Row** — Two cards side by side: wagon class and Wi-Fi status with color-coded states.

### 6.3 Animation Requirements

- Screen transitions: fade in/out, 220ms, disabled when reduced motion is on.
- Train header track animation: continuous horizontal scroll based on speed, disabled when reduced motion is on.
- Bottom bar selection: `animateContentSize()` equivalent (SwiftUI `.animation`).

### 6.4 Localization Strings

All user-facing strings must be externalized in `Localizable.xcstrings` (Xcode 15+) or `.strings` files. Support:
- `de` (German, default)
- `en` (English)

Approximately 180 strings total.

---

## 7. Platform-Specific iOS Considerations

| Feature | Android Implementation | iOS Equivalent |
|---|---|---|
| Foreground Service + Notification | `IceNotificationService` with custom `RemoteViews` | **Live Activity** (iOS 16.1+) using `ActivityKit` |
| Home Screen Widget | Jetpack Glance | **WidgetKit** SwiftUI widget |
| SharedPreferences | `SettingsManager` | `UserDefaults` (standard) / `AppStorage` |
| DataStore (widget state) | Glance DataStore | `UserDefaults` with App Group |
| HTTP Client | Ktor | `URLSession` |
| JSON Parsing | Kotlinx Serialization | `Codable` |
| Map | OSMDroid | **MapKit** (preferred) or OpenStreetMap via `MapLibre` |
| In-App Updates | Google Play Core | **Not applicable** — App Store handles updates |
| Crash Reporting | Firebase Crashlytics | **Firebase Crashlytics** (opt-in) or **Sentry** |
| Polling | `CoroutineScope` + `delay` | `Task` + `Task.sleep` or `Timer` |
| Navigation | Jetpack Navigation | `NavigationStack` + `TabView` |
| Edge-to-Edge | `enableEdgeToEdge()` | `ignoreSafeArea()` + `containerBackground` |

---

## 8. Out of Scope (for initial release)

- Apple Watch app or complications
- Siri Shortcuts / App Intents
- iPad multitasking / Stage Manager optimizations
- macOS Catalyst port
- Push notifications (not needed; Live Activity replaces the Android notification)
- Core Data or local database caching
- User accounts or authentication
- Offline trip history
