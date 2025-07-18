//
//  AppDelegate.swift
//  AutoClicker
//
//  Created by Erin on 7/15/25.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var globalMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()

        // Global hotkey monitor
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains([.control, .option, .command]) && event.charactersIgnoringModifiers == "q" {
                print("Hotkey pressed: Control + Option + Command + Q")
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up the monitor when the app quits
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
