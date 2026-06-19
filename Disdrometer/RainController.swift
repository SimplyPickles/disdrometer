// Disdrometer
//
// The central coordinator for the application. It manages the lifecycle of
// the overlay windows and persists user settings via UserDefaults.
// It acts as the single source of truth for the UI and the rendering layers.
//
// Created by Dylan Fraser on 6/17/26.
//

import AppKit
import Combine

final class RainController: ObservableObject {
  // Published settings (drive the menu bar UI + live-update windows)

  @Published var isRunning: Bool {
    didSet {
      UserDefaults.standard.set(isRunning, forKey: "isRunning")
      isRunning ? start() : stop()
    }
  }

  @Published var intensity: Float {
    didSet {
      UserDefaults.standard.set(intensity, forKey: "intensity")
      applyToAllWindows { $0.intensity = intensity }
    }
  }

  @Published var angleDegrees: Double {
    didSet {
      UserDefaults.standard.set(angleDegrees, forKey: "angleDegrees")
      applyToAllWindows { $0.angleDegrees = CGFloat(angleDegrees) }
    }
  }

  @Published var fallSpeed: Double {
    didSet {
      UserDefaults.standard.set(fallSpeed, forKey: "fallSpeed")
      applyToAllWindows { $0.fallSpeed = CGFloat(fallSpeed) }
    }
  }

  @Published var opacity: Double {
    didSet {
      UserDefaults.standard.set(opacity, forKey: "opacity")
      applyToAllWindows { $0.opacity = CGFloat(opacity) }
    }
  }


  @Published var dimEnabled: Bool {
    didSet {
      UserDefaults.standard.set(dimEnabled, forKey: "dimEnabled")
      applyToAllWindows { $0.dimEnabled = dimEnabled }
    }
  }

  @Published var dimOpacity: Double {
    didSet {
      UserDefaults.standard.set(dimOpacity, forKey: "dimOpacity")
      applyToAllWindows { $0.dimOpacity = CGFloat(dimOpacity) }
    }
  }

  @Published var dropStyle: DropStyle {
    didSet {
      UserDefaults.standard.set(dropStyle.rawValue, forKey: "dropStyle")
      applyToAllWindows { $0.dropStyle = dropStyle }
    }
  }

  private var windows: [RainWindow] = []
  private var splashTimer: Timer?

  init() {
    // Load saved values from UserDefaults, fallback to defaults
    isRunning = UserDefaults.standard.object(forKey: "isRunning") as? Bool ?? true
    intensity = UserDefaults.standard.object(forKey: "intensity") as? Float ?? 20
    angleDegrees = UserDefaults.standard.object(forKey: "angleDegrees") as? Double ?? -30
    fallSpeed = UserDefaults.standard.object(forKey: "fallSpeed") as? Double ?? 200
    opacity = UserDefaults.standard.object(forKey: "opacity") as? Double ?? 0.4

    // Load new persistence settings
    dimEnabled = UserDefaults.standard.object(forKey: "dimEnabled") as? Bool ?? false
    dimOpacity = UserDefaults.standard.object(forKey: "dimOpacity") as? Double ?? 0.3
    let styleRaw =
      UserDefaults.standard.string(forKey: "dropStyle") ?? DropStyle.crispDrops.rawValue
    dropStyle = DropStyle(rawValue: styleRaw) ?? .crispDrops
  }

  func start() {
    guard windows.isEmpty else { return }
    rebuildWindowsForScreens()
  }

  func stop() {
    windows.forEach { $0.orderOut(nil) }
    windows.removeAll()
    splashTimer?.invalidate()
    splashTimer = nil
  }

  /// Tears down and recreates one RainWindow per currently connected
  /// screen. Called on first launch and whenever screen configuration
  /// changes (monitor plugged/unplugged, resolution change, etc).
  func rebuildWindowsForScreens() {
    windows.forEach { $0.orderOut(nil) }
    windows.removeAll()

    for screen in NSScreen.screens {
      let window = RainWindow(screen: screen)
      (window.contentView as? RainView)?.intensity = intensity
      (window.contentView as? RainView)?.angleDegrees = CGFloat(angleDegrees)
      (window.contentView as? RainView)?.fallSpeed = CGFloat(fallSpeed)
      (window.contentView as? RainView)?.opacity = CGFloat(opacity)
      (window.contentView as? RainView)?.dimEnabled = dimEnabled
      (window.contentView as? RainView)?.dimOpacity = CGFloat(dimOpacity)
      (window.contentView as? RainView)?.dropStyle = dropStyle
      window.orderFrontRegardless()
      windows.append(window)
    }
  }

  private func applyToAllWindows(_ block: (RainView) -> Void) {
    for window in windows {
      if let rainView = window.contentView as? RainView {
        block(rainView)
      }
    }
  }
}
