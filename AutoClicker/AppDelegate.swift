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
    var localMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        
        // Global hotkey monitor (works when app is NOT focused)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains([.control, .option, .command]) && event.charactersIgnoringModifiers == "q" {
                print("Global Hotkey pressed: Control + Option + Command + Q")
                ClickController.shared.stopClicking() // Stop clicking instead of quitting
            }
        }

//        // Global hotkey monitor
//        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
//            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
//            if flags.contains([.control, .option, .command]) && event.charactersIgnoringModifiers == "q" {
//                print("Hotkey pressed: Control + Option + Command + Q")
//                NSApplication.shared.terminate(nil)
//            }
//        }
        
        // Local hotkey monitor (works when app IS focused)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.control, .option, .command]) &&
                event.charactersIgnoringModifiers == "q" {
                print("Local Hotkey pressed: Control + Option + Command + Q")
                ClickController.shared.stopClicking()
                return nil // don't pass the event through to system
            }
            return event
        }

    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up the monitor when the app quits
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
