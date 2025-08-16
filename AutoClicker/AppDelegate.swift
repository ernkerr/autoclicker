//
//  AppDelegate.swift
//  AutoClicker
//
//  Created by Erin on 7/15/25.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var statusBarController: StatusBarController?
    var globalMonitor: Any?
    var localMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        statusBarController = StatusBarController()
        
        // Configure window transparency and remove controls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.configureWindow()
        }
        
        // Hide the dock icon but keep the app running
      NSApp.setActivationPolicy(.accessory)
//        
        // Global hotkey monitor (works when app is NOT focused)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains([.control, .option, .command]) {
                if event.charactersIgnoringModifiers == "q" {
                    print("Global Hotkey pressed: Control + Option + Command + Q")
                    ClickController.shared.stopClicking()
                } else if event.charactersIgnoringModifiers == "s" {
                    print("Global Hotkey pressed: Control + Option + Command + S")
                    AppDelegate.shared?.showMainWindow()
                }
            }
        }
        
        // Local hotkey monitor (works when app IS focused)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.control, .option, .command]) {
                if event.charactersIgnoringModifiers == "q" {
                    print("Local Hotkey pressed: Control + Option + Command + Q")
                    ClickController.shared.stopClicking()
                    return nil
                } else if event.charactersIgnoringModifiers == "s" {
                    print("Local Hotkey pressed: Control + Option + Command + S")
                    AppDelegate.shared?.showMainWindow()
                    return nil
                }
            }
            return event
        }
    }
    
    func showMainWindow() {
         // Double approach since it works on second click
         NSApp.activate(ignoringOtherApps: true)
         
         if let window = NSApp.windows.first(where: { !$0.isKind(of: NSPanel.self) }) {
             // First attempt
             window.makeKeyAndOrderFront(nil)
             
             // Second attempt after brief delay (since it works on second click)
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                 window.makeKeyAndOrderFront(nil)
                 window.orderFrontRegardless()
             }
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
//            window.alphaValue = 0
            
            window.isOpaque = false
            window.hasShadow = false
            
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
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }
}

