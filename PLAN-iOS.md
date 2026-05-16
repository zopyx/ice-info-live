# ICE Info — iOS Implementation Plan

## Phase 0: Project Setup & Foundation

### Tasks

- [x] 0.1 Create Xcode project with SwiftUI lifecycle, iOS 18.0 minimum, iPhone-only
  - Bundle identifier: `com.nruge.iceinfo` (matching Android) or `com.nruge.iceinfo.ios`
  - Disable Swift Testing initially (test targets added per-phase)
- [x] 0.2 Configure Info.plist
  - `NSAppTransportSecurity` with `NSExceptionDomains` for `iceportal.de` (allow HTTP)
  - Required background modes (for Live Activity updates)
  - Supported localizations: German (de), English (en)
- [x] 0.3 Add Firebase SDK via SPM (optional, for Crashlytics)
  - Conditional: only link when explicitly decided
- [x] 0.4 Set up App Group for Widget data sharing
  - `group.com.nruge.iceinfo` shared container
- [x] 0.5 Create project directory structure:

```
ICE Info/
├── App/
│   ├── ICEInfoApp.swift              # @main entry point
│   ├── ContentView.swift             # Root tab view + state orchestration
│   └── AppDelegate.swift             # (if Firebase needed)
├── Models/
│   ├── ApiModels.swift               # StatusResponse, TripResponse, etc.
│   ├── TrainModels.swift             # TrainStatus, TrainStop, etc.
│   └── SampleData.swift              # Demo data (Hamburg→München)
├── Network/
│   ├── TrainRepository.swift         # ICE Portal API client
│   ├── DepartureBoardRepository.swift # DB transport.rest client
│   └── APIError.swift                # Error types
├── ViewModels/
│   └── MainViewModel.swift           # Central @Observable ViewModel
├── Views/
│   ├── StatusView.swift              # Home/Status tab
│   ├── StopsView.swift               # Stop timeline tab
│   ├── MapView.swift                 # Map tab
│   ├── ServiceView.swift             # Service info tab
│   ├── ConnectionsView.swift         # Connections tab
│   ├── NoWifiView.swift              # Offline/not connected
│   ├── Components/
│   │   ├── TrainHeader.swift         # Animated train header
│   │   ├── TravelSummaryCard.swift   # Journey progress card
│   │   ├── ConnectivityRow.swift     # WiFi + wagon class
│   │   ├── DelayBadge.swift          # Delay indicator
│   │   ├── DelayReasonCard.swift     # Delay reason
│   │   ├── TimelineStopRow.swift     # Stop timeline item
│   │   ├── StopTimePair.swift        # Time display component
│   │   ├── PoiCard.swift             # POI display
│   │   ├── ConnectionRow.swift       # Connecting train row
│   │   ├── DepartureRow.swift        # Departure board row
│   │   ├── TrainTypeBadge.swift      # Train type badge
│   │   ├── AppCard.swift             # Card wrapper
│   │   └── WavyProgressView.swift    # Animated wavy progress
│   └── Sheets/
│       ├── SettingsSheet.swift       # Settings bottom sheet
│       ├── InfoSheet.swift           # App info
│       ├── ChangelogSheet.swift      # Version history
│       ├── DebugSheet.swift          # API response viewer
│       ├── OnboardingSheet.swift     # First launch
│       └── CrashConsentSheet.swift   # Crash reporting consent
├── Utilities/
│   ├── SettingsManager.swift         # UserDefaults wrapper
│   ├── TimeUtils.swift               # Delay/time formatting
│   ├── IceUtils.swift                # TZN → ICE class mapping
│   └── NetworkMonitor.swift          # SSID / connectivity detection
├── Resources/
│   ├── Localizable.xcstrings         # DE + EN strings
│   ├── Assets.xcassets               # App icon, train icons, brand colors
│   └── Fonts/                        # SpaceGrotesk + Inter (or SF Pro)
├── Widget/
│   └── TrainWidget.swift             # WidgetKit provider + views
├── LiveActivity/
│   └── TrainLiveActivity.swift       # ActivityKit attributes + views
└── Info.plist
```

### Files to create

- `App/ICEInfoApp.swift`
- `App/ContentView.swift`
- `Models/ApiModels.swift`
- `Models/TrainModels.swift`
- `Models/SampleData.swift`
- Directory structure (all directories)

### Verification

- [ ] App launches on iPhone 18.0 simulator
- [ ] Tab bar visible with 5 placeholder tabs
- [ ] DE + EN localizations loadable
- [ ] No warnings or errors

---

## Phase 1: Networking Layer

### Tasks

- [x] 1.1 Implement `TrainRepository.swift`
  - `URLSession` with async/await
  - HTTPS→HTTP fallback logic (try HTTPS first, catch, retry HTTP)
  - Timeout: request 5s, connect 3s, socket 5s
  - Generic `getWithFallback<T: Decodable>(path:)` method
  - Same raw text fallback for POI parsing
  - All 4 endpoints: status, trip, POIs, connections

- [x] 1.2 Implement `DepartureBoardRepository.swift`
  - Single endpoint: departures by EVA number
  - Parameters: `when` (ISO datetime), `duration` (90), `results` (30)
  - Timeout: request 8s, connect 4s, socket 8s

- [x] 1.3 Implement API models (`ApiModels.swift`)
  - All `Codable` structs: `StatusResponse`, `TripResponse`, `ApiStop`, `Station`, `StopInfo`, `Timetable`, `Track`, `DelayReason`, `ConnectionResponse`, `ApiConnection`, `Connectivity`, `PoiResponse`
  - Property naming: `CodingKeys` for snake_case → camelCase mapping
  - Default values for all optional fields (matching Kotlin defaults)

- [x] 1.4 Implement domain models (`TrainModels.swift`)
  - `TrainStatus`, `TrainStop`, `ConnectingTrain`, `Departure`, `PoiItem`
  - `AppTheme` enum with `Codable` conformance
  - Mapping function: `mapToTrainStatus(apiStatus:trip:)` in repository

- [x] 1.5 Implement `APIError.swift`
  - Error types: `.invalidURL`, `.noData`, `.decodingError(Error)`, `.httpError(Int)`, `.networkError(Error)`, `.allHostsFailed`

- [x] 1.6 Implement POI response parsing for dual-format compatibility
  - Check if response is JSON array (bare list) or object (`{"pois": [...]}`)
  - Decode accordingly

### Verification

- [ ] Repository can fetch real data from ICE portal
- [ ] Fallback to HTTP works when HTTPS fails
- [ ] POI parsing handles both JSON formats
- [ ] Departure board fetches work
- [ ] All errors handled gracefully (return empty/fallback)

---

## Phase 2: Domain Logic & ViewModel

### Tasks

- [x] 2.1 Implement `MainViewModel.swift`
  - `@Observable` class
  - Published state: `trainStatus`, `pois`, `connections`, `departures`
  - Published settings: `isMockMode`, `demoSpeed`, `reducedMotion`
  - Wifi status flag
  - Polling loop via `Task` (3s interval) — cancellable via `isActive` check
  - POI fetching bundled with main poll loop
  - Connection fetching on target stop change + poll loop
  - Departure board fetching on target stop change + poll loop
  - Widget state update after each poll

- [x] 2.2 Implement target stop selection logic
  - `setTargetStop(eva:)` persists to `UserDefaults` + updates ViewModel state
  - `relevantBoardStop()`: prefers target stop, falls back to next upcoming
  - Re-fetches connections + departures for new station
  - Notifies widget and Live Activity of change

- [x] 2.3 Implement mock mode switching
  - `setMockMode(enabled:)` replaces all data with sample data
  - Persists state to `UserDefaults`
  - Speed slider in mock mode updates `demoSpeed` on the sample data

- [x] 2.4 Implement connection reachability logic
  - Train's effective arrival = scheduled + delay
  - Connection's effective departure = scheduled + delay (if actual > 0)
  - Reachable if departure > arrival (or departure > now if no arrival time)
  - Transfer minutes = difference in minutes
  - Tight if transfer < 5 min

- [x] 2.5 Implement `SettingsManager.swift` (or use `@AppStorage`)
  - Keys: `targetStopEva`, `isMockMode`, `demoSpeed`, `appTheme`, `reducedMotion`, `language`, `crashReportingEnabled`, `crashConsentVersion`, `onboardingShown`
  - Shared `UserDefaults` with app group suite for widget data

- [x] 2.6 Implement `TimeUtils.swift`
  - `calculateDelayMinutes(actual:scheduled:)` — epoch ms difference
  - `formatRemainingTime(distance:speed:)` — distance/speed → "Xh Ymin"
  - `formatRemainingTimeUntil(arrival:delay:)` — "Xh Ymin" from now

- [x] 2.7 Implement `IceUtils.swift`
  - `getIceClass(tzn:)` — TZN string → human-readable ICE class
  - `getIceDrawable(tzn:)` — TZN → asset image name (SF Symbol or custom)

- [x] 2.8 Implement `SampleData.swift`
  - Full sample `TrainStatus` (ICE 212 Hamburg→München)
  - 10 stops covering: passed, cancelled, additional, various delays
  - 5 sample POIs
  - 5 sample connecting trains
  - 7 sample departures
  - All matching Android `DemoDaten.kt`

### Verification

- [ ] ViewModel polling works with 3s interval
- [ ] Target stop selection persists across app restarts
- [ ] Demo mode shows sample data, live mode shows real data
- [ ] Connection reachability logic correctly marks missed/tight/reachable
- [ ] Time formatting matches Android output
- [ ] ICE class labels match Android

---

## Phase 3: Status Tab UI

### Tasks

- [x] 3.1 Implement `StatusView.swift`
  - ScrollView with vertical layout, 16pt padding
  - Components stacked with 16pt spacing
  - Background color matching theme

- [x] 3.2 Implement `AppCard.swift`
  - Card wrapper with rounded corners, padding, shadow/elevation
  - Matches Android `AppCard` composable look

- [x] 3.3 Implement `TrainHeader.swift`
  - Animated train tracks (repeating image scrolling) using `TimelineView` or `Timer` + `PhaseAnimator`
  - Disabled when `reducedMotion` is on
  - ICE model icon based on TZN
  - Train type + number in DB red, italic, large title
  - ICE class label below
  - Speed in km/h, DB red, bold
  - Uses `GeometryReader` for track width calculation
  - Track offset animation speed proportional to actual train speed

- [x] 3.4 Implement `TravelSummaryCard.swift`
  - Target stop name with arrow
  - Remaining distance in km
  - Remaining stops count or progress "X of Y"
  - Wavy linear progress indicator (custom animated shape) or standard progress
  - Wave speed proportional to train speed
  - ETA + remaining time
  - Delay badge (or "On time")

- [x] 3.5 Implement `DelayBadge.swift`
  - Red background for >= 5 min delay
  - Green background for < 5 min delay OR green text/no badge for 0
  - "+N" or "Pünktlich" / "On time" label

- [x] 3.6 Implement `ConnectivityRow.swift`
  - HStack with two equal-width cards
  - Wagon class card: "KLASSE" label, "1" or "2"
  - WiFi card: current state label + predicted next state
  - Diagonal split when next state available
  - Color coding by state (green/orange/red/gray)

- [x] 3.7 Implement `DelayReasonCard.swift`
  - Shown conditionally when `delayReason` is non-empty
  - Icon + reason text in primary container color

- [x] 3.8 Implement target stop picker (inline in StatusView)
  - Dropdown menu with upcoming stops
  - Current selection highlighted with checkmark
  - Shows scheduled arrival time per stop
  - "No target" option to clear selection
  - Matches Android `StopSelectionDialog` / dropdown behavior

- [x] 3.9 Implement demo speed slider (conditional)
  - Shown only in demo mode
  - Collapsible card header
  - Slider 0–300 km/h with ticks
  - Current value displayed
  - "0 km/h" / "150 km/h" / "300 km/h" labels

### Verification

- [ ] Status tab matches Android layout
- [ ] Train header animates tracks at speed-proportional rate
- [ ] Travel summary card shows correct progress, distance, ETA
- [ ] Connectivity row shows correct colors for each state
- [ ] Stop picker dropdown works correctly
- [ ] Demo slider appears only in demo mode
- [ ] All strings localized (DE + EN)

---

## Phase 4: Stops Tab UI

### Tasks

- [x] 4.1 Implement `StopsView.swift`
  - ScrollView with vertical layout
  - Stop timeline card + POI card
  - Empty state when no stops available

- [x] 4.2 Implement `TimelineStopRow.swift`
  - Three-column layout: time column (left) | timeline (center) | station info (right)
  - Time column: 88pt wide, arrival time pair + departure time pair
  - Timeline: vertical line + circle/icon indicator
    - Passed: small filled circle, primary color
    - Next: larger circle with train icon, primary color
    - Pending: outlined circle
    - Cancelled: X icon in error color
  - Station info: name, cancelled badge, track, additional stop badge
  - Row highlight for next stop (primary container background)
  - Strikethrough for cancelled stops
  - Color dimming for passed stops

- [x] 4.3 Implement `StopTimePair.swift`
  - Scheduled time with line-through when delayed
  - Actual time: green (< 5 min delay), red (>= 5 min delay)
  - Monospace font
  - Bold for actual time when delayed or next stop
  - Dimmed for passed stops

- [x] 4.4 Implement `PoiCard.swift`
  - Section title "Points of Interest"
  - List of POI items sorted by distance
  - Icon by type (CITY, RIVER, MOUNTAIN, LAKE, MONUMENT, FOREST)
  - Type label, name, description
  - Distance chip (m or km)
  - Tap opens `google.com/search?q=<name>` in Safari
  - Dividers between items

### Verification

- [ ] Timeline visualization matches Android
- [ ] All stop states (passed, next, pending, cancelled, additional) display correctly
- [ ] POIs display with correct icons and distances
- [ ] Tap on POI opens Google Search
- [ ] Proper spacing and alignment

---

## Phase 5: Map Tab

### Tasks

- [x] 5.1 Implement `MapView.swift`
  - `Map` with `MapCameraPosition` (iOS 17+ MapKit)
  - Animated marker at train's lat/lon
  - Map region updates to follow train position
  - Proper inset for tab bar + safe areas

- [x] 5.2 Handle edge cases
  - No position data (0,0): show placeholder or last known region
  - Animation smoothness: use `withAnimation` for marker moves

### Verification

- [ ] Map shows train location
- [ ] Marker animates smoothly as train moves
- [ ] Map centers/re-centers appropriately
- [ ] Handles nil/zero coordinates gracefully

---

## Phase 6: Connections Tab

### Tasks

- [x] 6.1 Implement `ConnectionsView.swift`
  - ScrollView with connections card + departures card
  - Header showing station name and our arrival time

- [x] 6.2 Implement `ConnectionRow.swift`
  - Layout: departure time | train info (type badge + number + destination) | track + reachability
  - Time pair: scheduled + actual (if delayed), monospace font
  - `TrainTypeBadge` component (small rounded rect with type text)
  - Track badge
  - Reachability badge: "Reachable" (green), "Tight" (orange, < 5min), "Missed" (red)
  - Transfer minutes display

- [x] 6.3 Implement `DepartureRow.swift`
  - Similar layout: time | line info | platform
  - Cancelled badge
  - Delayed time highlighting
  - Line parsed into type badge + number (e.g., "ICE 372")

- [x] 6.4 Implement `TrainTypeBadge.swift`
  - Small rounded background with bold type text
  - Muted variant for cancelled items
  - Light/dark mode colors

### Verification

- [ ] Connections tab matches Android layout
- [ ] Reachability badges show correct state
- [ ] Departure board displays correctly
- [ ] Empty state when no connections available

---

## Phase 7: Sheets, Dialogs & Settings

### Tasks

- [x] 7.1 Implement `SettingsSheet.swift`
  - Theme picker: Light / Dark / System (segmented picker)
  - Demo Mode toggle
  - Demo Speed Display toggle (show slider)
  - Reduced Motion toggle
  - Language picker: Deutsch / English
  - Crash Reporting toggle
  - Debug button → opens DebugSheet

- [x] 7.2 Implement `InfoSheet.swift`
  - App icon, name, version
  - API URLs
  - Privacy information
  - Legal disclaimer
  - Data source attribution

- [x] 7.3 Implement `ChangelogSheet.swift`
  - Version list with feature descriptions
  - Markdown or formatted text

- [x] 7.4 Implement `OnboardingSheet.swift`
  - Multi-page or single-scroll onboarding explaining app features
  - Auto-shown on first launch (or after update)
  - Dismiss button (no skip)

- [x] 7.5 Implement `CrashConsentSheet.swift`
  - Explanation of crash reporting
  - Accept / Decline buttons
  - Shown on first install and after each app update

- [x] 7.6 Implement `DebugSheet.swift`
  - Raw JSON responses from API (trip + connections)
  - Device info
  - Copy button (copies to clipboard)
  - Share button (share sheet)

### Verification

- [ ] Settings open and close correctly
- [ ] Theme toggle immediately changes appearance
- [ ] Mock mode toggle switches between live/demo
- [ ] Language change takes effect
- [ ] Crash consent dialog only shown when needed
- [ ] Onboarding only shown once
- [ ] Debug sheet shows raw data with copy/share

---

## Phase 8: Notification Service & Live Activity

### Tasks

- [x] 8.1 Register for Live Activities in project capabilities
- [x] 8.2 Implement `TrainLiveActivity.swift`
  - ActivityAttributes: `TrainAttributes` with train info
  - ContentState: speed, next stop, ETA, delay, target stop name
  - Dynamic Island: compact leading (speed), compact trailing (delay), minimal (speed)
  - Expanded: full train info layout
  - Lock screen: progress bar, train info, ETA
  - Start tracking button → pushes Live Activity
  - Stop button → ends Live Activity

- [x] 8.3 Implement Live Activity update polling
  - When Live Activity is active, use background Task to update every 5s
  - Exponential backoff on failure (up to 60s)
  - Update via `Activity<T>.update(using:)`

- [x] 8.4 Implement local notification fallback for pre-Live Activity
  - `UNNotificationRequest` with timer-based display
  - Same layout as Live Activity expanded state
  - Updates via removing + re-posting

- [x] 8.5 Notification permission request
  - Request on first "start tracking" attempt
  - Handle grant/deny gracefully

### Verification

- [ ] Live Activity starts and updates every 5 seconds
- [ ] Dynamic Island shows correct info
- [ ] Stop button ends the activity
- [ ] Fallback notification works on older iOS
- [ ] Permission request shown on first start

---

## Phase 9: Home Screen Widget

### Tasks

- [x] 9.1 Add Widget Extension target
- [x] 9.2 Implement `TrainWidget.swift`
  - `AppIntentConfiguration` (iOS 17+) or `StaticConfiguration`
  - Timeline provider reads latest data from shared `UserDefaults`
  - Small widget: speed, train type+number, next stop, delay badge
  - Medium widget: additional details (destination ETA, track, progress bar)
  - "Exit now!" state when train is at the target stop (0 distance remaining)

- [x] 9.3 Set up shared `UserDefaults` suite in app group
  - App writes latest `TrainStatus` JSON to shared defaults after each poll
  - Widget reads and displays

- [x] 9.4 Background refresh
  - `BGTaskScheduler` for periodic refresh when app is not running
  - Timeline reload after app writes new data

### Verification

- [ ] Widget appears in widget gallery
- [ ] Widget updates with live data when app is running
- [ ] "Exit now!" state works correctly
- [ ] Both small and medium configurations work

---

## Phase 10: SSID Detection & Connection States

### Tasks

- [x] 10.1 Implement `NetworkMonitor.swift`
  - Use `NEHotspotNetwork` (`fetchCurrent`) or `CNCopyCurrentNetworkInfo`
  - Check if SSID contains "WIFIonICE" (or exact match)
  - Periodic check every 5 seconds

- [x] 10.2 Implement `NoWifiView.swift`
  - Shown when not connected to WIFIonICE
  - Train silhouette illustration
  - "Not connected to WIFIonICE" message
  - Connection tips
  - "Try again" button → triggers immediate connection check
  - "Demo mode" button → switches to demo data

- [x] 10.3 Handle connection state transitions
  - Connected → disconnected: show NoWifiView, stop polling
  - Disconnected → connected: start polling, show main UI
  - Use `.animation` for smooth transitions

### Verification

- [ ] App detects WIFIonICE SSID when connected
- [ ] NoWifiView shows when not connected to train WiFi
- [ ] Retry button re-checks connection
- [ ] Demo mode accessible from NoWifiView

---

## Phase 11: Theming & Branding

### Tasks

- [x] 11.1 Define brand colors in `Assets.xcassets` color set
  - `DBRot`, `DBRotDark`, `DBDunkelblau`, `DBHellgrau`, `DBMittelgrau`, `DBDunkelgrau`
  - `DBGruen`, `DBGruenHell`, `DBBlau`, `DBBlauHell`
  - Light mode + dark mode variants matching Android `Color.kt`

- [x] 11.2 Implement theme manager
  - `AppTheme` enum (light / dark / system)
  - Override via `preferredColorScheme()` on root view
  - Store in `UserDefaults`

- [x] 11.3 Set up custom fonts
  - Space Grotesk Bold + Inter Regular (matching Android)
  - Or: use SF Pro with matching weight/size mapping
  - Register in `Info.plist` or via SwiftUI `.font()` customization

- [x] 11.4 Implement reduced motion support
  - Check `UIAccessibility.isReduceMotionEnabled` + in-app override
  - Disable train header animation
  - Disable view transition animations

### Verification

- [ ] Light mode matches Android light theme
- [ ] Dark mode matches Android dark theme (DB dark blue background)
- [ ] Theme toggle works correctly
- [ ] Reduced motion disables all animations
- [ ] Custom fonts render correctly (or SF Pro fallback)

---

## Phase 12: Final Integration & Polish

### Tasks

- [x] 12.1 Wire up `ContentView.swift` as the root coordinator
  - TabView with 5 tabs
  - NoWifiView vs main UI conditional
  - Dialog/sheet state management
  - ViewModel as `@State` object

- [x] 12.2 Implement `ContentView.swift` logic:
  - Check SSID → show NoWifi or main app
  - Manage all sheet states from one place
  - Pass ViewModel state to all child views
  - Handle `onAppear`/`onDisappear` for polling lifecycle

- [x] 12.3 Animation polish
  - Tab transitions
  - Train header track scrolling
  - Wavy progress indicator animation
  - Map marker animation
  - List appearance animations

- [x] 12.4 ViewState/loading states
  - Skeleton/placeholder during initial load
  - Error state when network fails
  - Retry buttons on errors
  - Progress indicators during loading

- [x] 12.5 Accessibility audit
  - Dynamic Type labels
  - VoiceOver labels on all components
  - Proper accessibility traits (button, header, etc.)
  - Sufficient contrast ratios

- [x] 12.6 Localization verification
  - All user-facing strings in `Localizable.xcstrings`
  - German + English complete coverage
  - No hardcoded strings

### Verification

- [ ] Full app flow works end-to-end
- [ ] All 5 tabs render correctly
- [ ] SSID detection triggers correct views
- [ ] All sheets/dialogs open and function
- [ ] Animations smooth and correct
- [ ] Accessibility VoiceOver navigable
- [ ] German + English strings complete

---

## Dependencies

### External (Swift Package Manager)

| Package | Purpose |
|---------|---------|
| Firebase Crashlytics | Crash reporting (optional) |

### Internal

- All other dependencies: Foundation, SwiftUI, MapKit, ActivityKit, WidgetKit, UserNotifications — all system frameworks

---

## Key Architectural Decisions

1. **No DI framework**: Manual injection via ViewModel init/Environment. Matches Android's no-DI approach.
2. **Single ViewModel**: One `@Observable` class for all app state (mirroring Android's single `MainViewModel`). If this grows too large, split into domain-specific ViewModels in a future phase.
3. **Shared UserDefaults for widget**: JSON-serialized `TrainStatus` in app group container.
4. **Live Activity over foreground service**: iOS doesn't support persistent foreground services like Android. Live Activity is the closest equivalent for showing persistent train tracking.
5. **Network fallback first**: Always try HTTPS before HTTP for ICE portal.
6. **POI dual-format parsing**: Handle both bare array and wrapped object JSON responses from different ICE firmware versions.

## Build Configuration

- iOS 18.0 minimum
- Swift 6 language mode
- Strict concurrency checking (complete)
- No third-party networking libraries (URLSession + Codable only)
