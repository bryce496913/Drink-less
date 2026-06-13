# DrinkKind

DrinkKind is an iOS 16+ SwiftUI app for planning and tracking mindful drinking with local-only storage.

## Build & Run
1. Open `DrinkKind.xcodeproj` in Xcode 15+.
2. Select the `DrinkKind` scheme and an iOS 16+ simulator.
3. Build and run.

## Architecture
- **MVVM**: SwiftUI views consume state from `AppContainer` and service layer.
- **Services**: `PlanService`, `LoggingService`, `AnalyticsService`, `TipService`, `NotificationService`, `DateService`.
- **Persistence**: Core Data via `PersistenceController` with entities for profile, settings, and day logs.
- **Charts**: Apple Swift Charts in the Progress tab.
- **Notifications**: Local daily reminder via `UNUserNotificationCenter`.

## Features
- Multi-step onboarding and editable settings.
- Weekly plan with dry-day toggles and auto-pick.
- Today quick-add logging and 30-day history editing.
- Tip-of-the-day from local JSON.
- Progress charts, summaries, and 14-day insights.
- CSV export can be added from current `DataStore` logs.

## Testing
- `DrinkKindTests/PlanServiceTests.swift`
- `DrinkKindTests/AnalyticsServiceTests.swift`

Run in Xcode test navigator or with command-line xcodebuild on macOS:
```bash
xcodebuild test -project DrinkKind.xcodeproj -scheme DrinkKind -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Privacy
All app data stays on device. DrinkKind is fully offline and does not perform server sync or online checks.

## App Identity
- App target, product, module, and shared scheme: `DrinkKind`
- Main bundle identifier: `com.brycedevelopment.DrinkKind`
- Unit-test target and bundle identifier: `DrinkKindTests` / `com.brycedevelopment.DrinkKindTests`

The Core Data model intentionally retains its internal `MindfulSipModel` name to preserve the existing persistence schema identity.
