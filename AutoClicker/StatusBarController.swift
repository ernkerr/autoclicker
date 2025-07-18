//
//  StatusBarController.swift
//  AutoClicker
//
//  Created by Erin on 7/17/25.
//

import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var targetPoint: NSPoint? // save coordinates
    private var globalMonitor: Any?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cursorarrow", accessibilityDescription: "Auto Clicker")
        }

        constructMenu()
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

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q"))
        statusItem.menu = menu
    }

    @objc func selectTarget() {
        print("Select Target clicked - enter picking mode")

        // Remove existing monitor if exists
        if globalMonitor != nil {
            NSEvent.removeMonitor(globalMonitor!)
            globalMonitor = nil
        }

        // Add a new monitor that listens for the next left mouse click
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            // Get the location of the mouse click in screen coordinates
            let location = NSEvent.mouseLocation

            // Save the point
            self?.targetPoint = location

            print("Selected point: \(location)")

            // Remove monitor so we only capture one click
            if let monitor = self?.globalMonitor {
                NSEvent.removeMonitor(monitor)
                self?.globalMonitor = nil
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
