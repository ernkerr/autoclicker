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
        
        // Configure window transparency and remove controls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.configureWindow()
        }
        
        // Global hotkey monitor (works when app is NOT focused)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains([.control, .option, .command]) && event.charactersIgnoringModifiers == "q" {
                print("Global Hotkey pressed: Control + Option + Command + Q")
                ClickController.shared.stopClicking()
            }
        }
        
        // Local hotkey monitor (works when app IS focused)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.control, .option, .command]) &&
                event.charactersIgnoringModifiers == "q" {
                print("Local Hotkey pressed: Control + Option + Command + Q")
                ClickController.shared.stopClicking()
                return nil
            }
            return event
        }
    }
    
    private func configureWindow() {
        for window in NSApplication.shared.windows {
            // Remove window controls (red, yellow, green dots)
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // Configure for glassmorphism
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = true
            // window.level = .floating // Keep window on top
            
            // Enable dragging from anywhere in the window
            window.isMovableByWindowBackground = true
            
            // Completely remove title bar and frame
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask = [.borderless, .resizable]
            window.styleMask.insert(.fullSizeContentView)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
