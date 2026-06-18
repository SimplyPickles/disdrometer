//
//  RainWindow.swift
//  Disdrometer
//
//  Created by Dylan Fraser on 6/17/26.
//  This is THE trick the whole app hinges on: a borderless, transparent,
//  click-through NSWindow that sits over (or under) everything else and
//  follows you across Spaces.
//
//  One of these gets created per NSScreen so rain covers every monitor.
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
        // --- Visual transparency ---
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false

        // --- Layering ---
        // .floating sits above normal app windows but below things like
        // the Spotlight overlay. If you want rain to appear OVER the Dock
        // too (like Lo-rain does), bump this to .statusBar or even
        // .screenSaver. Tradeoffs:
        //   .floating     -> above app windows, dock still on top
        //   .statusBar    -> above the Dock and menu bar
        //   .screenSaver  -> above basically everything, use sparingly
        level = .statusBar

        // --- Click-through ---
        // This is the single most important line in the file. Without it,
        // this window would swallow every click on your desktop.
        ignoresMouseEvents = true

        // --- Multi-space behavior ---
        // canJoinAllSpaces: follow the user across Spaces/full-screen apps.
        // stationary: don't animate this window during Space transitions.
        // fullScreenAuxiliary: allowed to show alongside full-screen apps.
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .fullScreenAuxiliary,
            .ignoresCycle,
        ]

        // Don't let this window become key/main, and don't release it on
        // close (we manage its lifecycle manually from RainController).
        // The "don't show in window-cycling / Mission Control" behavior
        // is already covered by .ignoresCycle in collectionBehavior above.
        isReleasedWhenClosed = false

        // Cover the full screen, including under the menu bar.
        setFrame(screen.frame, display: true)

        // The actual rain rendering lives in RainView, attached as the
        // content view. See RainView.swift.
        let rainView = RainView(frame: screen.frame)
        rainView.autoresizingMask = [.width, .height]
        contentView = rainView
    }

    // A borderless window can't become key by default; we don't want it to
    // anyway (it should never steal focus from whatever you're doing).
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
