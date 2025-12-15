# AppVersion

A lightweight, pure Swift package to track the installed version of your iOS app, detect upgrades, and manage version history.

## Features

- **Automatic Version Tracking**: Easily track the current app version from `Bundle.main`.
- **Upgrade Detection**: Instantly know if the current launch is an upgrade from a previous version.
- **Version History**: Keep a complete history of all previously installed versions.
- **First Launch Detection**: Identify if it's the very first time the user has launched your app.
- **Thread Safe**: Actors-ready with `@MainActor` support.

## Installation

### Swift Package Manager

Add `AppVersion` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/AppVersion.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to **File > Add Packages...**
2. Enter the repository URL.
3. Choose the version strategy (e.g., Up to Next Major).

## Usage

### Initialization

Call `AppVersionTracker.shared.track()` as early as possible in your app's lifecycle, such as in the `init` of your `App` struct or `AppDelegate`.

```swift
import SwiftUI
import AppVersion

@main
struct MyApp: App {
    init() {
        // Track the version immediately on launch
        AppVersionTracker.shared.track()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Checking for Upgrades

You can check if the app was just upgraded and get the previous version. This is useful for showing "What's New" screens or performing migration tasks.

```swift
if AppVersionTracker.shared.isUpgrade {
    if let oldVersion = AppVersionTracker.shared.previousVersion {
        print("Upgraded from \(oldVersion) to \(AppVersionTracker.shared.currentVersion)")
    }
}
```

### First Launch

Check if this is the first time the user has opened the app.

```swift
if AppVersionTracker.shared.isFirstLaunch {
    print("Welcome to the app for the first time!")
}
```

### Version History

Access the full list of versions ever installed on the device.

```swift
for version in AppVersionTracker.shared.history {
    print("Installed version: \(version)")
}
```

## API Reference

### `AppVersionTracker`

- `shared`: The singleton instance.
- `track()`: Updates the tracking information. Should be called once per launch.
- `currentVersion`: The current version string (e.g., "1.0.0").
- `previousVersion`: The version installed before the current one, if any.
- `history`: An array of strings representing all tracked versions.
- `isFirstLaunch`: `Bool` indicating if this is the first launch.
- `isUpgrade`: `Bool` indicating if the current version is different from the last tracked version.

## Requirements

- iOS 13.0+ / macOS 10.15+ (or whatever your target minimums are)
- Swift 5.5+

## License

This project is licensed under the MIT License.
