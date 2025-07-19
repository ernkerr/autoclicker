//
//  ClickController.swift
//  AutoClicker
//
//  Created by Erin on 7/18/25.
//

import Foundation
import Combine
import AppKit

class ClickController: ObservableObject {
    static let shared = ClickController()

    @Published var isRunning = false
    @Published var clicksPerSecond: Double = 1
    @Published var interval: Double = 1
    @Published var isIntervalMode = false
    @Published var progress: Double = 0
    @Published var isDoubleClickEnabled = false

    private var timer: Timer?
    private var clickCount = 0
    private let maxClicks = 10
    private var targetPoint: CGPoint?
    private var globalMonitor: Any?

    private init() {}

    func toggleClicking() {
        isRunning.toggle()
        isRunning ? startClicking() : stopClicking()
    }

    func startClicking() {
        guard let storedPoint = targetPoint else {
            print("❌ No target point selected.")
            isRunning = false
            return
        }

        clickCount = 0
        let delay = isIntervalMode ? interval : 1.0 / clicksPerSecond

        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] _ in
            guard let self = self, let safePoint = self.targetPoint else { return }

            DispatchQueue.main.async {
                print("🧵 Timer on thread: \(Thread.current)")
                self.performClick(at: safePoint)
                self.clickCount += 1
                self.progress = Double(self.clickCount) / Double(self.maxClicks)

                // Uncomment if you want to stop after maxClicks
//                if self.clickCount >= self.maxClicks {
//                    self.stopClicking()
//                }
            }
        }

        print("🟢 Started clicking at \(storedPoint), interval: \(delay)s")
    }

    func stopClicking() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        progress = 0
        clickCount = 0
        print("🔴 Stopped clicking")
    }

    // New function: click with cursor save and restore
    func clickWithCursorRestore(at point: CGPoint) {
        // Save original cursor position
        let originalPos = NSEvent.mouseLocation

        // Convert to flipped coordinates for CGEvent
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedPoint = CGPoint(x: point.x, y: screenHeight - point.y)

        // Move cursor to target
        let moveToTarget = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: flippedPoint, mouseButton: .left)
        moveToTarget?.post(tap: .cghidEventTap)

        // Create click down and up events
        let eventSource = CGEventSource(stateID: .hidSystemState)
        let clickDown = CGEvent(mouseEventSource: eventSource, mouseType: .leftMouseDown, mouseCursorPosition: flippedPoint, mouseButton: .left)
        let clickUp = CGEvent(mouseEventSource: eventSource, mouseType: .leftMouseUp, mouseCursorPosition: flippedPoint, mouseButton: .left)

        // Post click events
        clickDown?.post(tap: .cghidEventTap)
        clickUp?.post(tap: .cghidEventTap)

        // Restore cursor to original position after slight delay to avoid flicker
        let restoreCursor = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: originalPos, mouseButton: .left)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            restoreCursor?.post(tap: .cghidEventTap)
        }

        print("🖱️ Clicked at (unflipped): \(point), actual: \(flippedPoint), restored cursor to \(originalPos)")
    }

    func performClick(at point: CGPoint) {
        clickWithCursorRestore(at: point)

        if isDoubleClickEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.clickWithCursorRestore(at: point)
            }
        }
    }

    func selectTarget() {
        print("🎯 Select target enabled. Click anywhere...")

        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            let location = NSEvent.mouseLocation
            DispatchQueue.main.async {
                self?.targetPoint = location
                print("✅ Target set at (raw): \(location)")

                if let monitor = self?.globalMonitor {
                    NSEvent.removeMonitor(monitor)
                    self?.globalMonitor = nil
                }
            }
        }
    }

    func increaseRate() {
        if isIntervalMode {
            if interval > 1 {
                interval -= 1
            } else {
                isIntervalMode = false
                clicksPerSecond = 1
            }
        } else {
            clicksPerSecond += 1
        }
    }

    func decreaseRate() {
        if isIntervalMode {
            if interval < 60 {
                interval += 1
            }
        } else {
            if clicksPerSecond > 1 {
                clicksPerSecond -= 1
            } else {
                isIntervalMode = true
                interval = 1
            }
        }
    }
}
