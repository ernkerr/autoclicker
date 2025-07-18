//
//  StatusBarController.swift
//  AutoClicker
//
//  Created by Erin on 7/17/25.
//

import AppKit

//let clickController = ClickController()

class StatusBarController {
    private var statusItem: NSStatusItem
    private var targetPoint: NSPoint? // save coordinates
    private var globalClickMonitor: Any?
    private var globalKeyMonitor: Any?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cursorarrow", accessibilityDescription: "Auto Clicker")
        }

        constructMenu()
        setupGlobalHotkeyMonitor()
    }

    private func constructMenu() {
        let menu = NSMenu()

        let selectItem = NSMenuItem(title: "Select Target", action: #selector(selectTarget), keyEquivalent: "T")
        selectItem.target = self
        menu.addItem(selectItem)
        
        let startItem = NSMenuItem(title: "Start Clicking", action: #selector(startClicking), keyEquivalent: "S")
        startItem.target = self
        menu.addItem(startItem)

        let stopItem = NSMenuItem(title: "Stop Clicking", action: #selector(stopClicking), keyEquivalent: "P")
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func setupGlobalHotkeyMonitor() {
        // This listens for global key events (even outside the app)
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags.contains([.control, .option, .command]) && event.charactersIgnoringModifiers?.lowercased() == "q" {
                print("Global hotkey pressed: Control + Option + Command + Q")
                NSApplication.shared.terminate(nil)
            }
        }
    }

    @objc func selectTarget() {
        print("Select Target clicked - enter picking mode")

        if globalClickMonitor != nil {
            NSEvent.removeMonitor(globalClickMonitor!)
            globalClickMonitor = nil
        }

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            let location = NSEvent.mouseLocation
            self?.targetPoint = location
            print("Selected point: \(location)")
            if let monitor = self?.globalClickMonitor {
                NSEvent.removeMonitor(monitor)
                self?.globalClickMonitor = nil
            }
        }

        print("Now click anywhere to select the target point")
    }

    @objc func startClicking() {
        print("Start Clicking clicked")
    }

    @objc func stopClicking() {
        print("Stop Clicking clicked")
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
