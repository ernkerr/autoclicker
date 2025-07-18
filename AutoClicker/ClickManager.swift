//
//  ClickManager.swift
//  AutoClicker
//
//  Created by Erin on 7/17/25.
//

import Foundation
import AppKit

class ClickManager: ObservableObject {
    @Published var isRunning = false
    @Published var clicksPerSecond = 1.0
    @Published var interval = 1.0
    @Published var isIntervalMode = false
    @Published var progress = 0.0

    private var timer: Timer?
    private var targetPoint: CGPoint = NSEvent.mouseLocation
    private let maxClicksPerSecond = 50.0
    private let maxIntervalSeconds = 30.0

    func toggleClicking() {
        isRunning.toggle()
        if isRunning {
            startClicking()
        } else {
            stopClicking()
        }
    }

    func increaseRate() {
        if isIntervalMode {
            if interval < maxIntervalSeconds { interval += 1 }
        } else {
            if clicksPerSecond < maxClicksPerSecond { clicksPerSecond += 1 }
        }
    }

    func decreaseRate() {
        if isIntervalMode {
            if interval > 1 { interval -= 1 }
        } else {
            if clicksPerSecond > 1 { clicksPerSecond -= 1 }
            else {
                // Switch to interval mode
                isIntervalMode = true
                interval = 1
            }
        }
    }

    func startClicking() {
        let delay = isIntervalMode ? interval : 1.0 / clicksPerSecond
        progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            self.progress += 0.01 / delay
            if self.progress >= 1.0 {
                self.progress = 0
                self.click()
            }
        }
    }

    func stopClicking() {
        timer?.invalidate()
        timer = nil
        progress = 0
    }

    func click() {
        let eventDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: targetPoint, mouseButton: .left)
        let eventUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: targetPoint, mouseButton: .left)
        eventDown?.post(tap: .cghidEventTap)
        eventUp?.post(tap: .cghidEventTap)
    }

    func selectTargetPoint() {
        // Capture current mouse location
        targetPoint = NSEvent.mouseLocation
    }
}
