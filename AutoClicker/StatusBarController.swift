//
//  StatusBarController.swift
//  SmartClick
//
//  Created by Erin on 7/17/25.
//

import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "SmartClick - Assistive Auto Clicker")
        }

        constructMenu()
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
