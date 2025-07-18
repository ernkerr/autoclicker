//
//  AppDelegate.swift
//  AutoClicker
//
//  Created by Erin on 7/15/25.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }
}
