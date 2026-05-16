# ICE Info — iOS Requirements Specification

## 1. Product Overview

**ICE Info** is an unofficial companion app for Deutsche Bahn ICE trains. When the user is connected to the train's `WIFIonICE` network, it reads live telemetry from the onboard ICE Portal API and displays journey information in a modern, clean interface.

### 1.1 Core Value Proposition
- Real-time access to ICE telemetry data that is otherwise invisible to passengers
- No login required — works automatically when on `WIFIonICE`
- Pure companion experience — no tracking, no ads, no account

### 1.2 Target Platform
- iOS 18.0+ (to support latest SwiftUI, Live Activities, and Widget APIs)
- iPhone (portrait and landscape)
- iPad (optional — future, not in v1)

---

## 2. Data Sources & Networking

### 2.1 ICE Portal API (iceportal.de)

| Endpoint | Path | Returns | Poll Interval |
|----------|------|---------|---------------|
| Status | `/api1/rs/status` | Speed, position, train serial (TZN), wagon class, connectivity | 3s |
| Trip Info | `/api1/rs/tripInfo/trip` | Train type, train number, stops list (with times, track, delay reasons), actual position | 3s |
| POIs | `/api1/rs/pois/map/{minLat}/{minLon}/{maxLat}/{maxLon}` | Points of interest near the route | 3s (bundled with status poll) |
| Connections | `/api1/rs/tripInfo/connection/{evaNr}` | Connecting trains at a given station | On target stop change + every 3s |

**Firmware Compatibility**: Some ICE firmware versions return POIs as a bare JSON array (`[...]`) while others return `{"pois": [...]}`. Both must be handled.

**HTTPS Fallback**: Primary endpoint is HTTPS; falls back to HTTP for older trains that don't serve HTTPS. The app's `Info.plist` must include `NSAppTransportSecurity` exception for `iceportal.de` HTTP.

### 2.2 DB Transport REST API (v6.db.transport.rest)

| Endpoint | Path | Parameters | Returns | Poll Interval |
|----------|------|-----------|---------|---------------|
| Departures | `/stops/{evaNr}/departures` | `when` (ISO datetime), `duration` (90), `results` (30) | Departure board at the target/next station | On target stop change + every 3s |

### 2.3 WIFIonICE Detection

Detect connection to the train network by checking if the current SSID is `WIFIonICE`. On iOS, use `NEHotspotNetwork` or `CNCopyCurrentNetworkInfo` with appropriate entitlements.

---

## 3. Functional Requirements

### FR1: Train Telemetry Display (Status Tab)

The main screen shows real-time train information:

- **Train Header**: Animated train type/number header with moving track visualization and speed indicator
  - Train number (e.g., "ICE 212") in DB red
  - ICE class label (e.g., "ICE 4") derived from TZN
  - Current speed in km/h (large, bold)
  - Animated train tracks scrolling beneath the header (disabled with reduced motion)
  - ICE model icon matching the actual train class (derived from TZN)

- **Target Stop Selector**: Dropdown/picker to select a destination stop from the list of upcoming stops
  - Shows currently selected target stop name
  - When no target is selected, progress shows toward final destination
  - Persists selection across app launches

- **Travel Summary Card**: Journey progress card showing:
  - Target stop name with arrow prefix
  - Remaining distance in km
  - Remaining stops count
  - Animated wave progress indicator (or standard linear progress) showing fraction of route completed
  - ETA display with formatted remaining time
  - Delay badge (red for >= 5 min delay, green for < 5 min delay, or "On time" label)

- **Connectivity Row**: Two side-by-side cards:
  - Wagon class (1 or 2)
  - WiFi signal status: current state + predicted next state with remaining time
  - States: `STRONG` (green), `HIGH` (green), `MIDDLE`/`WEAK` (orange), `LOW`/`NO_CONNECTION` (red), `NO_INFO` (gray)
  - Diagonal split visualization showing current connectivity color and predicted next state color

- **Delay Reason Card**: Shown when there is an active delay reason text from the API

- **Demo Speed Slider**: Shown only in demo mode — slider from 0–300 km/h to simulate speed changes

### FR2: Stop Timeline (Stops Tab)

A vertical timeline of all train stops showing:

- **Timeline visualization** with passed/pending/next states:
  - Passed stops: small filled circle, connected by primary-colored line
  - Next stop: larger circle with train icon, highlighted row background
  - Pending stops: outlined circle, connected by gray line
  - Cancelled stops: X icon, name with strikethrough
  - Additional stops: "+" indicator with tertiary color

- **Time pairs** for each stop (arrival + departure when available):
  - Scheduled time shown crossed out when delayed
  - Actual time shown with color coding:
    - Green: on time or < 5 min delay
    - Red: >= 5 min delay
    - Dimmed: passed stops
    - Crossed out: cancelled

- **Track/platform number** for each stop

- **POIs Card**: Points of interest near the current leg:
  - Icon based on type (CITY, RIVER, MOUNTAIN, LAKE, MONUMENT, FOREST)
  - Name, type label, description
  - Distance chip (m or km)
  - Tap opens Google Search for the POI name
  - Sorted by distance ascending

### FR3: Live Map (Map Tab)

- **MapKit** integration showing the train's current position
- Animated marker at the train's latitude/longitude
- Map centered on train position with automatic region updates
- Proper handling of offline/low-connectivity scenarios

### FR4: Service Info (Service Tab)

- Placeholder tab with information about onboard services
- Currently marked as WIP in the Android app
- Can show static information or be omitted in v1

### FR5: Connecting Trains & Departures (Connections Tab)

- **Connecting trains** at the selected target stop (or next upcoming stop):
  - Train type badge (ICE, IC, RE, RB, S, etc.)
  - Train number
  - Destination
  - Departure time (scheduled + actual if delayed)
  - Track/platform badge
  - Reachability status:
    - Green "Reachable" with transfer minutes
    - Orange "Tight connection" (< 5 min transfer)
    - Red "Connection missed"
  - Reachability logic: compares our arrival time (scheduled + delay) with the connection's departure time (scheduled + delay)

- **Additional departures** from `v6.db.transport.rest`:
  - Line identifier
  - Destination
  - Scheduled time + delay
  - Platform
  - Cancelled indicator
  - Header shows station name and our arrival time

### FR6: Foreground Notification / Live Activity

- **Live Activity** (iOS 16.1+) showing:
  - Train type and number
  - Current speed
  - Next stop (or target stop if set) with ETA
  - Delay badge (if delayed)
  - A "Stop tracking" button
  - Dynamic Island support

- **Legacy fallback**: Local notification with timer for pre-iOS 16.1 devices
  - Updates every 5 seconds
  - Shows speed, next stop, ETA, distance, delay, progress, track info

### FR7: Home Screen Widget

- **WidgetKit widget** (iOS 16+) matching the Android Glance widget layout:
  - Train type + number
  - Speed
  - Next/target stop name
  - ETA with delay
  - Special "Exit now!" state when the train has arrived at the target stop
  - Small, medium configurations
  - Background refresh via polling or timeline provider

### FR8: Demo Mode

- Full offline demo with sample data (Hamburg → Munich route)
- Toggle from settings
- Adjustable speed slider (0–300 km/h)
- Sample data covers: passed stops, cancelled stops, additional stops, various delay levels, POIs, connecting trains, departures, connectivity states
- When enabled, replaces all live data with sample data
- Speed slider changes animate the journey progress

### FR9: Settings

Accessible via a toolbar button (gear icon):

- **Theme**: Light / Dark / System (three-way toggle)
- **Demo Mode**: Enable/disable offline demo
- **Demo Speed Display**: Toggle visibility of the speed slider on the home screen
- **Reduced Motion**: Disables animations (train header track scrolling, screen transitions)
- **Language**: German / English (system-independent override)
- **Crash Reporting**: Enable/disable anonymous crash reporting via Firebase Crashlytics
- **Debug**: Raw API response viewer with copy and share functionality

### FR10: Dialogs

- **Onboarding**: Shown on first launch explaining key features (how to connect, tabs, demo mode)
- **Crash Reporting Consent**: Shown on first install and after each app update
- **Info**: App version, privacy info, API URLs, legal disclaimers
- **Changelog**: Version history with new features/fixes

### FR11: Theme & Branding

- DB-brand color palette:
  - Primary: DB Red (`#EC0016`), dark variant (`#C0001A`)
  - Background: DB Dark Blue (`#131821`) in dark mode
  - Light gray (`#F0F3F5`) in light mode
  - Custom secondary, tertiary, error colors for both light and dark modes
- Custom fonts: Space Grotesk (bold) + Inter (regular) — or SF Pro equivalents with similar weight
- Dark blue button bar matching the train's actual control panel styling

---

## 4. Non-Functional Requirements

### NFR1: Architecture
- **MVVM** with SwiftUI `ObservableObject`/`@Observable` and `@Published` properties
- **Swift concurrency** (`async/await`, `AsyncSequence`, `AsyncStream`) for networking
- No third-party DI framework — use manual injection or SwiftUI Environment
- Clear separation: API layer → Repository layer → ViewModel → View

### NFR2: Networking
- `URLSession` with async/await
- Request timeout: 5s (connect), 5s (resource)
- Exponential backoff on failure (up to 60s max)
- `NSAppTransportSecurity` exception for `iceportal.de`
- Cache policy: `.reloadIgnoringLocalCacheData`

### NFR3: Data Persistence
- `UserDefaults` (or `@AppStorage`) for:
  - Target stop EVA number
  - Demo mode state
  - Demo speed
  - Theme preference
  - Language preference
  - Reduced motion preference
  - Crash reporting consent
  - Onboarding shown flag
  - Last version code for crash consent re-prompt

### NFR4: State Management
- Central `ObservableObject` ViewModel publishing all UI state
- Polling loop (3s interval) managed via Swift `Task` with cancellation
- Separate polling for: train status/POIs, connections/departures
- Widget state shared via `UserDefaults` with app group container

### NFR5: Localization
- German (default) and English
- All user-facing strings localized
- System language detection

### NFR6: Minimum Deployment
- iOS 18.0+
- iPhone only (v1)
- Portrait and landscape support

### NFR7: Accessibility
- Dynamic Type support
- VoiceOver labels on all interactive elements
- Reduce Motion respect (system setting + in-app toggle)
- Sufficient color contrast ratios
- Monospace font for time displays

### NFR8: Crash Reporting
- Firebase Crashlytics (or alternative)
- Opt-in consent with re-prompt after each app update
- Disabled by default

---

## 5. Data Models (Swift Codable)

### 5.1 API Models

```swift
struct StatusResponse: Codable {
    let speed: Double
    let latitude: Double
    let longitude: Double
    let tzn: String
    let wagonClass: String
    let connectivity: Connectivity?
}

struct Connectivity: Codable {
    let currentState: String    // STRONG, HIGH, MIDDLE, WEAK, LOW, NO_CONNECTION, NO_INFO
    let nextState: String?
    let remainingTimeSeconds: Int?
}

struct TripResponse: Codable {
    let trip: TripInfo?
}

struct TripInfo: Codable {
    let trainType: String
    let vzn: String           // train number
    let actualPosition: Int
    let stops: [ApiStop]
}

struct ApiStop: Codable {
    let station: Station?
    let info: StopInfo?
    let timetable: Timetable?
    let track: Track?
    let delayReasons: [DelayReason]?
    let cancelled: Bool
}

struct Station: Codable {
    let name: String
    let evaNr: String
}

struct StopInfo: Codable {
    let passed: Bool
    let distance: Int
    let distanceFromStart: Int
    let status: Int           // 0=normal, 2=additional, 3=cancelled
}

struct Timetable: Codable {
    let scheduledArrivalTime: Int64
    let actualArrivalTime: Int64
    let scheduledDepartureTime: Int64
    let actualDepartureTime: Int64
}

struct Track: Codable {
    let actual: String
}

struct DelayReason: Codable {
    let text: String
}

struct ConnectionResponse: Codable {
    let connections: [ApiConnection]?
}

struct ApiConnection: Codable {
    let trainType: String
    let vzn: String
    let finalStation: String
    let timetable: Timetable?
    let track: Track?
    let missed: Bool
}
```

### 5.2 Domain Models

```swift
enum AppTheme: String { case light, dark, system }

struct TrainStatus: Codable {
    let trainType: String
    let trainNumber: String
    let speed: Int
    let nextStop: String
    let destination: String
    let eta: String
    let delayMinutes: Int
    let track: String
    let delayReason: String
    let distanceToNext: Int
    let distanceLastToNext: Int
    let nextStopEva: String
    let stops: [TrainStop]
    let wagonClass: String
    let connectivity: String
    let nextConnectivity: String?
    let connectivityRemainingSeconds: Int?
    let tzn: String
    let latitude: Double
    let longitude: Double
    let distanceToDestination: Int
    let actualPosition: Int
    let destinationEta: String
    let destinationTrack: String
    let destinationDelay: Int
    let isConnected: Bool
    let targetStopEva: String?
}

struct TrainStop: Codable, Identifiable {
    var id: String { evaNr + name }
    let name: String
    let evaNr: String
    let scheduledArrival: String
    let actualArrival: String
    let delayMinutes: Int
    let track: String
    let passed: Bool
    let isNext: Bool
    let distanceFromStart: Int
    let scheduledArrivalMs: Int64
    let isAdditional: Bool
    let scheduledDeparture: String
    let actualDeparture: String
    let departureDelayMinutes: Int
    let isCancelled: Bool
    var effectiveArrivalMs: Int64 { ... }  // computed
}

struct ConnectingTrain: Codable, Identifiable {
    var id: String { trainType + trainNumber + departure }
    let trainType: String
    let trainNumber: String
    let destination: String
    let departure: String
    let track: String
    let delayMinutes: Int
    let reachable: Bool
    let transferMinutes: Int?
}

struct Departure: Codable, Identifiable {
    var id: String { line + scheduledTime }
    let line: String
    let destination: String
    let scheduledTime: String
    let delayMinutes: Int
    let platform: String
    let cancelled: Bool
}

struct PoiItem: Codable, Identifiable {
    let name: String
    let type: String
    let distance: Int
    let latitude: Double
    let longitude: Double
    let description: String
}
```

---

## 6. UI Structure

### 6.1 Tab Navigation

| Tab | Icon | Label (DE) | Label (EN) | SwiftUI |
|-----|------|------------|------------|---------|
| Status | train silhouette | Status | Status | `TabView` tab |
| Stops | list/bullet | Halte | Stops | `TabView` tab |
| Map | map | Karte | Map | `TabView` tab |
| Service | restaurant/utensils | Service | Service | `TabView` tab |
| Connections | sync/transfer | Anschlüsse | Connections | `TabView` tab |

### 6.2 Main Views

1. **StatusView**: TrainHeader, StopPicker, TravelSummaryCard, ConnectivityRow, DelayReasonCard (conditional), DemoSpeedSlider (conditional)
2. **StopsView**: ScrollView with TimelineStopRow for each stop, POIsCard below
3. **MapView**: MapKit view centered on train coordinates
4. **ServiceView**: Placeholder
5. **ConnectionsView**: ConnectingTrainsCard, DeparturesCard
6. **NoWifiView**: Shown when not on WIFIonICE, with retry and demo mode buttons

### 6.3 Sheets/Dialogs

1. **SettingsSheet**: Theme picker, demo mode toggle, demo speed toggle, reduced motion toggle, language, crash reporting, debug button
2. **InfoSheet**: App version, privacy, API URLs, legal
3. **ChangelogSheet**: Version history
4. **OnboardingSheet**: Feature explanation (first launch)
5. **CrashConsentSheet**: Crash reporting opt-in
6. **DebugSheet**: Raw API response viewer with copy/share

---

## 7. Connectivity Visualization

The connectivity states map to:

| API Value | Label (DE) | Label (EN) | Visual Color |
|-----------|-----------|-----------|-------------|
| `STRONG` / `HIGH` | Stark | Strong | Green |
| `MIDDLE` / `WEAK` | Schwach | Weak | Orange |
| `NO_CONNECTION` / `LOW` | Keine | None | Red |
| `NO_INFO` | — | — | Gray |

When a `nextState` is available with `remainingTimeSeconds`, the card shows a diagonal split: current state color + predicted next state color.

---

## 8. ICE Class Detection (from TZN)

| TZN Prefix | ICE Class |
|-----------|-----------|
| `ICE 1` prefix range | ICE 1 |
| `ICE 2` prefix range | ICE 2 |
| `ICE 3` prefix range | ICE 3 |
| `ICE 3neo` prefix range | ICE 3neo |
| `ICE 4` prefix range | ICE 4 |
| `ICE T` prefix range | ICE T |

Mapping logic from Android app's `IceUtils.kt` must be reimplemented.

---

## 9. Widget Requirements

- WidgetKit widget with `StaticConfiguration` or `AppIntentConfiguration`
- Auto-refresh via polling from the main app (storing latest state in shared `UserDefaults`)
- Small widget: speed, train number, next stop, delay
- Medium widget: additional detail (track, destination ETA)
- Special "Exit now!" state when at target stop
- Background refresh using `BGTaskScheduler` in case the app is not running
