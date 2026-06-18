//
//  DisdrometerApp.swift
//  Disdrometer
//
//  Entry point for the menu-bar-only rain overlay app. The app deliberately
//  uses an accessory activation policy so it stays out of the Dock and exists
//  as a small menu-bar agent.
//
//  Created by Dylan Fraser on 6/17/26.
//

import SwiftUI

@main
struct DisdrometerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // MenuBarExtra gives us the little menu bar icon + dropdown for free.
        // This is the only "visible" UI surface in the whole app.
        MenuBarExtra("Rain", systemImage: "cloud.rain.fill") {
            MenuBarView(controller: appDelegate.rainController)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let rainController = RainController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Belt-and-suspenders in case Info.plist LSUIElement isn't set yet
        // while you're iterating in Xcode.
        NSApp.setActivationPolicy(.accessory)

        rainController.start()

        // Rebuild overlay windows if the user adds/removes a monitor or
        // changes resolution.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.rainController.rebuildWindowsForScreens()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        rainController.stop()
    }
}
