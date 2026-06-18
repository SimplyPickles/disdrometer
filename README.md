# Disdrometer

A macOS menu-bar app that overlays realistic rain animations on your desktop.

## Features

- **Menu-bar control**: Access settings from the menu bar without cluttering your Dock
- **Multi-monitor support**: Rain covers all connected displays
- **Real-time customization**: Adjust intensity, fall speed, wind angle, opacity, and drop lifetime
- **Persistent settings**: Preferences saved automatically via UserDefaults
- **Click-through**: Rain overlays don't interfere with desktop interactions

## Requirements

- macOS 13.0+ (for SwiftUI `MenuBarExtra`)
- Xcode 14+

## Building

Open `Disdrometer/Disdrometer.xcodeproj` in Xcode and build. The app runs as a menu-bar agent (no Dock icon) by default.

## Architecture

```
DisdrometerApp.swift    → Entry point, NSApplication setup, screen change observation
MenuBarView.swift       → Menu-bar dropdown UI with sliders and toggle
RainController.swift    → Settings state + RainWindow lifecycle management
RainWindow.swift        → Borderless, click-through overlay window (one per screen)
RainView.swift          → Core animation-based rain rendering using CAEmitterLayer
```

## Settings

| Setting | Range | Description |
|---------|-------|-------------|
| Intensity | 20-400 drops/s | Raindrop generation rate |
| Fall Speed | 200-1600 pt/s | Vertical velocity of drops |
| Wind Angle | -30° to 30° | Horizontal drift direction |
| Opacity | 0.1-1.0 | Visual transparency |
| Lifetime | 1-15 s | How long each drop exists |
