# ICE Info Live — iOS Reimplementation Plan

## 1. Project Setup & Tooling (Week 1)

### 1.1 Xcode Project Structure
```
ICEInfoLive/
├── ICEInfoLive/                 # Main app target
│   ├── App/
│   │   ├── ICEInfoLiveApp.swift
│   │   └── AppDelegate.swift    # Firebase, lifecycle
│   ├── Data/
│   │   ├── API/
│   │   │   ├── ICEPortalClient.swift
│   │   │   ├── TransportRestClient.swift
│   │   │   └── APIError.swift
│   │   ├── Models/
│   │   │   ├── APIModels.swift      # Codable DTOs
│   │   │   └── DomainModels.swift   # App-level structs
│   │   └── Repositories/
│   │       ├── TrainRepository.swift
│   │       └── DepartureRepository.swift
│   ├── Services/
│   │   ├── SettingsService.swift
│   │   ├── WiFiDetectionService.swift
│   │   ├── LiveActivityManager.swift
│   │   └── WidgetUpdater.swift
│   ├── ViewModels/
│   │   └── AppViewModel.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── Screens/
│   │   │   ├── HomeView.swift
│   │   │   ├── StopsView.swift
│   │   │   ├── MapView.swift
│   │   │   ├── ServiceView.swift
│   │   │   └── ConnectionsView.swift
│   │   ├── Components/
│   │   │   ├── TrainHeader.swift
│   │   │   ├── AppCard.swift
│   │   │   ├── TravelSummaryCard.swift
│   │   │   ├── ConnectivityRow.swift
│   │   │   ├── DelayBadge.swift
│   │   │   ├── TimelineStopRow.swift
│   │   │   └── MapCard.swift
│   │   └── Sheets/
│   │       ├── SettingsSheet.swift
│   │       ├── InfoSheet.swift
│   │       └── OnboardingSheet.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Localizable.xcstrings
│   │   └── Fonts/
│   └── Info.plist
├── ICEInfoLiveWidget/           # WidgetKit extension
│   ├── ICEInfoLiveWidget.swift
│   ├── ICEInfoLiveWidgetBundle.swift
│   └── AppIntent.swift
├── ICEInfoLiveLiveActivity/     # Live Activity extension (optional bundle)
│   └── (shares code via framework)
├── ICEInfoLiveCore/             # Shared framework (optional)
│   └── (models, networking, settings)
└── ICEInfoLive.xcodeproj
```

### 1.2 Targets & Capabilities

| Target | Type | Capabilities |
|---|---|---|
| ICEInfoLive | iOS App | App Groups, Background Fetch, Location (optional), ATS |
| ICEInfoLiveWidget | Widget Extension | App Groups |
| ICEInfoLiveCore | Swift Framework | — |

### 1.3 Dependencies (SPM)

| Package | Version | Purpose |
|---|---|---|
| `firebase-ios-sdk` | ~11.0 | Crashlytics (opt-in) |
| `sentry-cocoa` | ~8.0 | Alternative crash reporting |

> **Decision:** Prefer **Sentry** over Firebase for lighter footprint and better SwiftUI support, or skip third-party crash reporting entirely and rely on Xcode Organizer + user opt-in.

### 1.4 Info.plist & ATS

```xml
<!-- Allow cleartext HTTP for iceportal.de only -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>iceportal.de</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

---

## 2. Phase Breakdown

### Phase 1: Foundation & Networking (Days 1–3)

**Goal:** A working network layer that can talk to both APIs and parse responses.

| Task | Details |
|---|---|
| 1.1 Create Xcode project | iOS 17.0+ deployment target, Swift 6 strict concurrency |
| 1.2 Define API models | Create `Codable` structs matching ICE Portal JSON (`StatusResponse`, `TripResponse`, `ApiStop`, etc.) and transport.rest JSON |
| 1.3 Build `ICEPortalClient` | `URLSession`-based client with HTTPS→HTTP fallback logic. Use custom `URLSessionDelegate` or a wrapper that retries with HTTP on `NSURLErrorSecureConnectionFailed` |
| 1.4 Build `TransportRestClient` | Standard HTTPS client for `v6.db.transport.rest` |
| 1.5 Build `TrainRepository` | `actor TrainRepository` with `fetchTrainStatus()`, `fetchPois()`, `fetchConnections()`. Merge `StatusResponse` + `TripResponse` into `TrainStatus` |
| 1.6 Build `DepartureRepository` | `fetchDepartures(evaNr:when:)` |
| 1.7 Add error handling | Define `APIError` enum (network, decoding, noData, httpFallback). Log with `os_log` |
| 1.8 Unit tests | Write tests using `URLProtocol` stubbing for both clients |

**Key Decisions:**
- Use `actor` for repositories to serialize mutable state (e.g., HTTP fallback flag).
- Use `JSONDecoder` with `.iso8601` or custom date decoding (API returns epoch ms for some fields, ISO strings for others).
- POI endpoint may return object or array — implement a custom `init(from decoder:)` or use `JSONSerialization` fallback.

**Verification:**
- [ ] Can fetch and parse real (or mocked) ICE Portal responses.
- [ ] Can fetch and parse transport.rest responses.
- [ ] Unit tests pass.

---

### Phase 2: Domain Layer & Settings (Days 4–5)

**Goal:** Clean domain models and persistent settings.

| Task | Details |
|---|---|
| 2.1 Map API → Domain | Write pure mapping functions: `StatusResponse + TripResponse → TrainStatus`, `ApiStop → TrainStop`, etc. |
| 2.2 Build `SettingsService` | Wrap `UserDefaults` (or `@AppStorage`) for: `targetStopEva`, `isMockMode`, `demoSpeed`, `onboardingShown`, `reducedMotion`, `appTheme`, `crashReportingEnabled`, `crashConsentVersion` |
| 2.3 Build `WiFiDetectionService` | Use `NEHotspotConfiguration` is not viable without entitlements. Simpler approach: check `CNCopyCurrentNetworkInfo` (deprecated but works with Hotspot helper entitlement) OR just use `URLSession` to probe `iceportal.de`. **Recommended:** Try to reach `https://iceportal.de/api1/rs/status`. If it responds, you're on the train. If not, show offline. |
| 2.4 Build `AppViewModel` | `@Observable class AppViewModel` (iOS 17) exposing `trainStatus`, `pois`, `connections`, `departures`, `isMockMode`, `isChecking`, `isOnTrain` |
| 2.5 Implement polling | `Task { while !Task.isCancelled { await fetch(); try await Task.sleep(.seconds(3)) } }` in ViewModel. Cancel on background. |
| 2.6 Demo data | Create `DemoData.swift` with a static `TrainStatus` sample. Toggle via settings. |

**Key Decisions:**
- Use `@Observable` (iOS 17) instead of `ObservableObject` + `@Published` for cleaner SwiftUI integration.
- For Wi-Fi detection, avoid private APIs. A reachability probe to `iceportal.de` is the most reliable and App-Store-safe method.

**Verification:**
- [ ] Settings persist across launches.
- [ ] Mock mode shows demo data correctly.
- [ ] Polling starts/stops correctly with app lifecycle.

---

### Phase 3: Core UI — Screens & Navigation (Days 6–10)

**Goal:** All five tab screens rendering data with the custom design system.

| Task | Details |
|---|---|
| 3.1 Theme system | Build `ICEInfoTheme` with `Color` extensions for DB palette. Support light/dark. Inject via `.environment(\.theme)` or just use adaptive colors. |
| 3.2 Typography | Define `Font` extensions for headline (bold rounded) and body (SF Pro). Embed custom fonts if needed. |
| 3.3 `AppCard` component | Reusable card with 20pt radius, shadow, outline border |
| 3.4 `MainTabView` | `TabView` with 5 tabs. Style the tab bar to match Android's pill shape OR use native iOS tab bar for better UX. **Decision:** Use native `TabView` styled with `.tabViewStyle(.page)` is wrong; use standard `TabView` with custom tab bar via `toolbar` or accept native styling. For visual parity, build a custom floating tab bar using `ZStack`. |
| 3.5 `HomeView` | Train header, target stop `Menu` or `Picker`, travel summary, connectivity row, delay reason card, demo slider |
| 3.6 `StopsView` | `List` or `ScrollView` with `TimelineStopRow`. Compute stop states (passed/current/upcoming) from `TrainStatus` |
| 3.7 `MapView` | `Map` (SwiftUI MapKit iOS 17+) with annotation at `trainStatus.coordinate`. Use `.mapStyle(.standard)` |
| 3.8 `ServiceView` | Placeholder text |
| 3.9 `ConnectionsView` | Connecting trains list + departures board. Reachability badges (green/orange/red) |
| 3.10 `TrainHeader` | SwiftUI `Canvas` or `Image` with parallax track offset animation. Use `withAnimation(.linear(duration: ...))` or `TimelineView`. Disable when `reducedMotion` is true. |

**Key Decisions:**
- Native `TabView` vs custom floating bar: **Recommendation:** Start with native `TabView` for accessibility and familiarity. If design parity is critical, build a custom floating bar in a `ZStack` over the content.
- MapKit vs OSM: **MapKit** is native, performant, and requires zero dependencies. The Android app uses OSMDroid mainly for open-source compliance; on iOS, MapKit is free and superior.
- SwiftUI `Map` (iOS 17) is sufficient; no need for `MKMapView` bridging.

**Verification:**
- [ ] All 5 tabs render correctly in light and dark mode.
- [ ] Train header animation works and respects reduced motion.
- [ ] Target stop selection updates all dependent cards.
- [ ] Demo mode slider controls speed display.

---

### Phase 4: Live Activity (Days 11–13)

**Goal:** Lock Screen / Dynamic Island Live Activity that mirrors the Android notification.

| Task | Details |
|---|---|
| 4.1 Add Live Activity target | Enable in Signing & Capabilities |
| 4.2 Define `ICEInfoWidgetAttributes` | Conform to `ActivityAttributes` with `ContentState` containing speed, nextStop, targetStop, eta, delay, progress, trainName |
| 4.3 Build widget UI | Compact, minimal, expanded, and dynamic island (compact/expanded) layouts in SwiftUI |
| 4.4 Build `LiveActivityManager` | Start / update / end activity. Called from `AppViewModel` when user toggles tracking |
| 4.5 Background updates | Use `BGAppRefreshTask` or simply update the Live Activity from the foreground app's polling loop. Live Activities can be updated from the app while it's in the foreground. For background, a `URLSession` background task or `BGTaskScheduler` is needed. |
| 4.6 Exit-now alert | Update `ContentState` with `isApproachingTarget` flag when within threshold (e.g., 5 min or 10 km). Change accent color to red in widget layout. |

**Key Decisions:**
- Live Activities are the iOS-native replacement for Android's foreground notification. They are more visually rich and appear on Lock Screen + Dynamic Island.
- Background updates are limited. The most reliable approach: update the Live Activity every time the app polls while in foreground. When the user locks the phone, the Live Activity shows the last state. Apple allows ~8 hours of active Live Activity updates.
- For true background polling, register a `BGAppRefreshTask` that fires every ~15 min. This is not as real-time as Android's foreground service, but it's the iOS constraint.

**Verification:**
- [ ] Live Activity starts and appears on Lock Screen.
- [ ] Dynamic Island shows compact + expanded views.
- [ ] Speed and ETA update as data changes.
- [ ] Exit-now alert triggers correctly.

---

### Phase 5: WidgetKit Home Screen Widget (Days 14–15)

**Goal:** Small and medium home screen widgets showing train info.

| Task | Details |
|---|---|
| 5.1 Add Widget extension | WidgetKit target |
| 5.2 Configure App Group | `group.com.nruge.iceinfo` — shared `UserDefaults` |
| 5.3 Build `WidgetUpdater` | Write train state to shared `UserDefaults` whenever `AppViewModel` receives new data |
| 5.4 Build widget UI | `ICEInfoWidget` with `systemSmall` and `systemMedium` families. Show train name, speed, next stop, target stop, delay, exit-now alert |
| 5.5 Reload timeline | Call `WidgetCenter.shared.reloadTimelines(ofKind:)` after updating shared defaults |

**Key Decisions:**
- Widgets are read-only and cannot poll on their own. They must be refreshed by the main app.
- Use `AppStorage` with an App Group container, or directly use `UserDefaults(suiteName:)`.

**Verification:**
- [ ] Widget appears in Home Screen gallery.
- [ ] Widget updates when app polls.
- [ ] Exit-now alert shows on widget.

---

### Phase 6: Polish — Onboarding, Settings, Localization (Days 16–18)

| Task | Details |
|---|---|
| 6.1 Onboarding sheet | First-launch feature carousel / sheet with 3–4 pages explaining the app |
| 6.2 Settings sheet | Theme segmented control, language toggle (de/en), reduced motion toggle, crash reporting toggle, debug toggle, demo mode toggle |
| 6.3 Localization | Create `Localizable.xcstrings`, extract all strings. Provide German and English translations. |
| 6.4 Info / About sheet | Version, privacy policy, legal, API attribution, changelog |
| 6.5 Crash reporting consent | Show alert on first launch of a new version. Store consent version. |
| 6.6 Debug sheet | Show raw JSON, copy to clipboard, share via `ShareLink` |
| 6.7 App icons | Generate iOS app icon set (all required sizes) from Android's adaptive icon assets |

**Verification:**
- [ ] Onboarding shows only on first launch.
- [ ] Language switch works and persists.
- [ ] All strings localized in German and English.
- [ ] Crash consent respects version code.

---

### Phase 7: Testing, Optimization, App Store Prep (Days 19–20)

| Task | Details |
|---|---|
| 7.1 Unit tests | Repository mapping, API client stubbing, ViewModel state transitions |
| 7.2 UI tests | Tab navigation, target stop selection, demo mode toggle |
| 7.3 Accessibility audit | VoiceOver, Dynamic Type, Reduce Motion |
| 7.4 Performance | Ensure no retain cycles, map doesn't leak, polling stops in background |
| 7.5 Battery | Optimize polling: reduce to 5s when Live Activity is active, 10s otherwise, stop entirely in background unless Live Activity is running |
| 7.6 App Store assets | Screenshots for 6.7" and 5.5" devices, app description, keywords, privacy policy URL |
| 7.7 Code signing & archive | Validate, upload to App Store Connect |

**Verification:**
- [ ] All unit tests pass.
- [ ] No memory leaks (check with Instruments).
- [ ] App Store Connect upload succeeds.

---

## 3. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                        │
│   HomeView │ StopsView │ MapView │ ServiceView │ ConnView   │
│   Sheets: Settings, Info, Onboarding, Debug                 │
└─────────────────────────┬───────────────────────────────────┘
                          │ @Observable
┌─────────────────────────▼───────────────────────────────────┐
│                      AppViewModel                           │
│  - Polling loop (Task.sleep)
│  - State: trainStatus, pois, connections, departures       │
│  - Mock mode management
│  - Calls LiveActivityManager & WidgetUpdater               │
└─────────────────────────┬───────────────────────────────────┘
                          │ async/await
┌─────────────────────────▼───────────────────────────────────┐
│                      Repositories                           │
│   TrainRepository (actor)    │   DepartureRepository (actor)│
│   - ICEPortalClient          │   - TransportRestClient      │
└─────────────────────────┬───────────────────────────────────┘
                          │ URLSession
┌─────────────────────────▼───────────────────────────────────┐
│                     Network Layer                           │
│   HTTPS → HTTP fallback        │   Codable decoding          │
│   Timeout & error handling                                   │
└─────────────────────────────────────────────────────────────┘

Sidecars:
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ SettingsService │  │ LiveActivityMgr │  │ WidgetUpdater   │
│ (UserDefaults)  │  │ (ActivityKit)   │  │ (App Group)     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 4. Technology Choices & Rationale

| Decision | Choice | Rationale |
|---|---|---|
| UI Framework | SwiftUI | Android uses Compose; SwiftUI is the direct counterpart. iOS 17+ gives us `Map`, `Observable`, and stable APIs. |
| Architecture | MVVM + `@Observable` | Clean separation, native SwiftUI data flow, no need for Combine. |
| Concurrency | `async/await` + `Task` | Direct replacement for Kotlin coroutines. `actor` for thread-safe repositories. |
| HTTP | `URLSession` | Native, no dependencies, supports ATS exceptions, easy stubbing for tests. |
| JSON | `Codable` | Native, compile-time safe, handles unknown keys via custom decoding. |
| Map | MapKit (`Map`) | Native, free, no attribution needed, works offline with cached tiles. |
| Widget | WidgetKit | Native iOS home screen widgets. |
| Background Updates | Live Activity + `BGAppRefreshTask` | iOS doesn't allow true foreground services. Live Activities are the sanctioned replacement. |
| Persistence | `UserDefaults` + App Group | Simple key-value storage; sufficient for settings and widget state. No need for Core Data. |
| Crash Reporting | Sentry (optional) | Lightweight, good SwiftUI support, EU-hosted option (important for German users). Firebase is also fine. |

---

## 5. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| App Store rejects app for using undocumented API to detect Wi-Fi SSID | High | High | Use reachability probe to `iceportal.de` instead of SSID detection. |
| Live Activity background updates are too limited for real-time train tracking | Medium | Medium | Document that the user should keep the app open for best accuracy. Use `BGAppRefreshTask` for coarse updates. |
| HTTP fallback for `iceportal.de` triggers App Store rejection | Low | High | Document the ATS exception clearly. The domain is legitimate and required for older train hardware. |
| transport.rest API changes or goes offline | Low | Medium | Gracefully hide the departures section if the API fails. |
| SwiftUI `Map` performance issues with rapid annotation updates | Low | Medium | Throttle map annotation updates; use `.animation(.none)` for coordinate changes. |
| No access to real ICE train for end-to-end testing | High | Medium | Rely heavily on demo mode and mock data. Ask beta testers who ride ICE trains frequently. |

---

## 6. Success Criteria

- [ ] App launches and displays live train data within 2 seconds when on WIFIonICE.
- [ ] All 5 tab screens are functional and visually polished.
- [ ] Live Activity shows on Lock Screen and Dynamic Island with real-time updates.
- [ ] Home screen widget updates correctly.
- [ ] Demo mode works fully offline.
- [ ] App is localized in German and English.
- [ ] No crashes in 7-day TestFlight beta with 10+ users.
- [ ] App Store review passes without rejection.
