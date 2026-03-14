# MindfulSip

MindfulSip is an iOS 16+ SwiftUI app for planning and tracking mindful drinking with local-only storage.

## Build & Run
1. Open `MindfulSip.xcodeproj` in Xcode 15+.
2. Select the `MindfulSip` scheme and an iOS 16+ simulator.
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
- `MindfulSipTests/PlanServiceTests.swift`
- `MindfulSipTests/AnalyticsServiceTests.swift`

Run in Xcode test navigator or with command-line xcodebuild on macOS:
```bash
xcodebuild test -project MindfulSip.xcodeproj -scheme MindfulSip -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Privacy
All app data stays on device. MindfulSip is fully offline and does not perform server sync or online checks.
