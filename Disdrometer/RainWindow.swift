//
//  RainWindow.swift
//  Disdrometer
//
//  Created by Dylan Fraser on 6/17/26.
//  Click-through NSWindow that sits over (or under) everything else and
//  follows you across Spaces
//
//  One gets created per NSScreen so rain covers every monitor
//

import AppKit

final class RainWindow: NSWindow {

  init(screen: NSScreen) {
    super.init(
      contentRect: screen.frame,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )

    configure(for: screen)
  }

  private func configure(for screen: NSScreen) {
    // Visual transparency
    backgroundColor = .clear
    isOpaque = false
    hasShadow = false

    level = .statusBar
    ignoresMouseEvents = true

    collectionBehavior = [
      .canJoinAllSpaces, // follow the user across spaces/full-screen apps
      .stationary, // don't animate this window during space transitions
      .fullScreenAuxiliary, // allowed to show alongside full-screen apps
      .ignoresCycle,
    ]

    // Don't let this window become key/main, and don't release it on
    // close (we manage its lifecycle manually from RainController)
    isReleasedWhenClosed = false

    // Cover the full screen, including area the menu bar covers
    setFrame(screen.frame, display: true)

    // The actual rain rendering lives in RainView, attached as the
    // content view
    let rainView = RainView(frame: screen.frame)
    rainView.autoresizingMask = [.width, .height]
    contentView = rainView
  }

  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
}
