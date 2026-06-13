# DrinkKind App Store Readiness Notes

## Permissions used

- **Local notifications**: used for optional daily check-ins, Monday planning prompts, and Booze Mode quick-add reminders. iOS local notification authorization is requested only after the user enables reminder-dependent features in Settings or onboarding.

## Data stored locally

DrinkKind stores user data on-device using Core Data and a small amount of UserDefaults state for weekly prompt/celebration timing. Stored data includes:

- Profile name and goal preference.
- Weekly drink target, dry-day target, baseline drink estimate, cost per drink, and calories per drink.
- App settings including reminders, reminder time, Booze Mode, Holiday Mode, and holiday date range.
- Daily drink logs, planned targets, dry-day plans, optional notes, drink entries, timestamps, and drink types.
- Non-sensitive UserDefaults flags for the most recent weekly setup prompt and weekly celebration.

The app does not include third-party SDKs, network calls, analytics tracking, advertising identifiers, location, health, camera, microphone, or photo access in the current codebase.

## Privacy manifest

`DrinkKind/Resources/PrivacyInfo.xcprivacy` declares no tracking and no collected data. It declares UserDefaults access with reason `CA92.1` because the app uses SwiftUI `@AppStorage` to store local app state.

## Branding and identifiers

- The app target, product, shared scheme, executable, and Swift module are named `DrinkKind`.
- The main app bundle identifier is `com.brycedevelopment.DrinkKind`.
- The unit-test bundle identifier is `com.brycedevelopment.DrinkKindTests`.
- The Core Data model remains internally named `MindfulSipModel` so persistence identity and model loading are not changed by the product rebrand.
- The app icon is unchanged and contains no product-name text.
- `LaunchBrand.imageset` and the repository-root `Splash.imageset` are not referenced by the current launch configuration, but their bitmap artwork still contains the former wordmark. Replace those source images with final DrinkKind artwork before re-enabling or submitting them as branded marketing assets.

## Likely App Privacy disclosures

Based on the current codebase, App Store Connect App Privacy responses should disclose data as **not collected** if data remains only on the user's device and is not transmitted off-device. If you later add sync, analytics, crash reporting, support upload, or any third-party SDK, update both App Store Connect privacy answers and the privacy manifest.

## Manual App Store Connect items still required

- Confirm the app icon and launch experience on a physical device and all required iPhone sizes.
- Prepare App Store screenshots.
- Prepare description, subtitle, promotional text, and keywords.
- Provide a privacy policy URL and support URL.
- Complete App Privacy responses.
- Complete the age rating questionnaire; alcohol-reduction/wellness content may require careful age-rating review.
- Ensure notification purpose messaging in metadata matches in-app behavior.
- Complete export compliance answers.
- Run a full TestFlight pass.
- Create and validate a Release archive in Xcode.
- Register `com.brycedevelopment.DrinkKind` in Apple Developer, enable only the capabilities the app actually uses, and regenerate the App Store provisioning profile.
- Create or update the DrinkKind app record in App Store Connect so its bundle ID matches `com.brycedevelopment.DrinkKind`.
- Select the correct development team and refreshed signing profile for the renamed `DrinkKind` target in Xcode.
