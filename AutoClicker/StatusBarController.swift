//
//  StatusBarController.swift
//  SmartClick
//
//  Created by Erin on 7/17/25.
//

import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var clickController: ClickController

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        clickController = ClickController.shared

        setupStatusIcon()
        constructMenu()
        
        // Observe clicking state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatusIcon),
            name: NSNotification.Name("ClickingStateChanged"),
            object: nil
        )
    }
    
    private func setupStatusIcon() {
        updateStatusIcon()
    }
    
    @objc private func updateStatusIcon() {
        if let button = statusItem.button {
            // Use simple cursor icon for both states - original design
            button.image = NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "SmartClick - Assistive Auto Clicker")
        }
    }

    private func constructMenu() {
        let menu = NSMenu()

        // Add show window menu item
        let showWindowItem = NSMenuItem(title: "Show SmartClick", action: #selector(showMainWindow), keyEquivalent: "S")
        showWindowItem.keyEquivalentModifierMask = [.control, .option, .command]
        showWindowItem.target = self
        menu.addItem(showWindowItem)
         
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
        quitItem.keyEquivalentModifierMask = [.control, .option, .command]
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc func showMainWindow() {
        AppDelegate.shared?.showMainWindow()
    }
    
    // maybe try to do this twice? since it takes two times to show? 

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
