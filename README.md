# Disdrometer

A macOS menu‑bar app that overlays realistic rain animations on your desktop. It provides a subtle, customizable weather effect that can be used for ambience, presentations, or just for fun.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Building](#building)
- [Architecture](#architecture)
- [Settings](#settings)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Menu‑bar control** – Access settings from the menu bar without cluttering your Dock.
- **Multi‑monitor support** – Rain covers all connected displays, each with its own overlay window.
- **Real‑time customization** – Adjust intensity, fall speed, wind angle, opacity, and drop lifetime on the fly.
- **Persistent settings** – Preferences saved automatically via `UserDefaults` and restored on launch.
- **Click‑through overlay** – Rain overlays are non‑intrusive; they do not block mouse clicks to underlying windows.
- **Low CPU/GPU footprint** – Leveraging `CAEmitterLayer` keeps the animation efficient.


## Requirements

- macOS 13.0+ (required for SwiftUI `MenuBarExtra`)
- Xcode 14+ (Swift 5.9)
- Swift Package Manager (used for any external dependencies, though the current project has none)

The app does not require any additional runtime libraries.




## Installation

### Pre‑built binary
Download the latest release from the **Releases** page, unzip, and move `Disdrometer.app` to your `/Applications` folder.

### Build from source
```sh
# Clone the repository
git clone https://github.com/yourusername/disdrometer.git
cd disdrometer

# Open the Xcode project and build
open Disdrometer/Disdrometer.xcodeproj
```

## Building

1. Open `Disdrometer/Disdrometer.xcodeproj` in Xcode.
2. Select the **Disdrometer** scheme.
3. Choose **Product → Build** (⌘B) or press ⌘B.
4. Run the app with **Product → Run** (⌘R) or press ⌘R.

The app runs as a menu‑bar agent (no Dock icon) by default.

### Command‑line build (optional)
If you prefer building from the terminal, you can use `xcodebuild`:
```sh
cd Disdrometer
xcodebuild -scheme Disdrometer -configuration Release
```
The built product will be located in `./build/Release/Disdrometer.app`.


## Architecture

The project follows a lightweight MVVM‑style architecture using SwiftUI for the menu‑bar UI and Core Animation for the rain effect.

```
DisdrometerApp.swift    → Entry point, NSApplication setup, screen change observation
MenuBarView.swift       → Menu‑bar dropdown UI with sliders and toggle
RainController.swift    → Settings state + RainWindow lifecycle management
RainWindow.swift        → Borderless, click‑through overlay window (one per screen)
RainView.swift          → Core animation‑based rain rendering using CAEmitterLayer
```


## Settings

The app exposes several parameters that can be tweaked in real time from the menu‑bar UI. All settings are persisted automatically via `UserDefaults`.

| Setting      | Range                | Description |
|--------------|----------------------|-------------|
| Intensity    | 20‑400 drops/s       | Raindrop generation rate |
| Fall Speed   | 200‑1600 pt/s        | Vertical velocity of drops |
| Wind Angle   | -30° to 30°          | Horizontal drift direction |
| Opacity      | 0.1‑1.0              | Visual transparency |
| Lifetime     | 1‑15 s               | How long each drop exists |

You can also reset all settings to their defaults via the **Reset** button in the menu.
