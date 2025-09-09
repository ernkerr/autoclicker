//
//  SmartClickApp.swift
//  SmartClick
//

import SwiftUI

@main
struct SmartClickApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .background(Color.clear)
        }
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())

    }
}
