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
    @Published var isSmartDelayEnabled = false
    @Published var isClickLimitEnabled: Bool = false
    @Published var maxClicks: Int = 100
    @Published var errorMessage: String? = nil


    private var timer: Timer?
    private var clickCount = 0
    private var targetPoint: CGPoint?
    private var globalMonitor: Any?
    private var progressTimer: Timer?   // new timer for smooth progress updates
    private var lastClickTime: Date?    // time of last click, for progress calculation
    private var delay: TimeInterval = 1 // how long between clicks (seconds)

    private init() {}

    func toggleClicking() {
        isRunning.toggle()
        isRunning ? startClicking() : stopClicking()
    }

    func startClicking() {
        guard let point = targetPoint else {
            print("❌ No target point selected.")
            errorMessage = "No target selected"

            isRunning = false
            return
        }

        clickCount = 0
        delay = isIntervalMode ? interval : 1.0 / clicksPerSecond
        lastClickTime = Date()
        progress = 0

        // Timer to perform clicks at fixed intervals
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.performClick(at: point)
            self.clickCount += 1
            
            // Reset progress tracking each click
            self.lastClickTime = Date()
            self.progress = 0

            if self.clickCount >= self.maxClicks {
                self.stopClicking()
            }
        }

        // Timer to update progress smoothly 20 times per second
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let lastClickTime = self.lastClickTime else { return }
            let elapsed = Date().timeIntervalSince(lastClickTime)
            self.progress = min(elapsed / self.delay, 1)
        }

        print("🟢 Started clicking at \(point), interval: \(delay)s")
    }

    func stopClicking() {
        timer?.invalidate()
        timer = nil

        progressTimer?.invalidate()   // stop progress updates too
        progressTimer = nil

        isRunning = false
        progress = 0

        print("🔴 Stopped clicking")
    }


    func performClick(at point: CGPoint) {
        let originalLocation = NSEvent.mouseLocation

        let clickAction = {
            self.moveCursorAndClick(at: point)
            self.restoreCursor(to: originalLocation)
            self.clickCount += 1
            
            if self.isClickLimitEnabled {
                self.progress = Double(self.clickCount) / Double(self.maxClicks)
                print("✅ Click \(self.clickCount)/\(self.maxClicks) performed")

                if self.clickCount >= self.maxClicks {
                    self.stopClicking()
                }
            } else {
                print("✅ Click \(self.clickCount) (unlimited mode)")
            }
        }

        if isSmartDelayEnabled {
            print("⏳ Waiting for mouse to become idle before clicking...")
            waitForMouseIdleThen(delay: 1.0, clickAction)
        } else {
            clickAction()
        }
    }

    func moveCursorAndClick(at point: CGPoint) {
        guard let screen = screenContaining(point) else {
            print("❌ Could not find screen for point: \(point)")
            return
        }
        let flippedPoint = flipPointVertically(point, on: screen)

        let moveEvent = CGEvent(mouseEventSource: nil,
                                mouseType: .mouseMoved,
                                mouseCursorPosition: flippedPoint,
                                mouseButton: .left)
        moveEvent?.post(tap: .cghidEventTap)

        // Double click
        for clickType in [CGEventType.leftMouseDown, .leftMouseUp,
                          .leftMouseDown, .leftMouseUp] {
            let clickEvent = CGEvent(mouseEventSource: nil,
                                     mouseType: clickType,
                                     mouseCursorPosition: flippedPoint,
                                     mouseButton: .left)
            clickEvent?.post(tap: .cghidEventTap)
        }

//        print("🖱️ Double clicked at (unflipped): \(point), actual: \(flippedPoint)")
    }

    func restoreCursor(to point: CGPoint) {
            let screenHeight = NSScreen.main?.frame.height ?? 0
            let flippedPoint = CGPoint(x: point.x, y: screenHeight - point.y)

            // Move the cursor back
            let moveEvent = CGEvent(mouseEventSource: nil,
                                    mouseType: .mouseMoved,
                                    mouseCursorPosition: flippedPoint,
                                    mouseButton: .left)
            moveEvent?.post(tap: .cghidEventTap)

            // Conditionally double-click after restore
            guard isDoubleClickEnabled else { return }

            for clickType in [CGEventType.leftMouseDown, .leftMouseUp,
                              .leftMouseDown, .leftMouseUp] {
                let clickEvent = CGEvent(mouseEventSource: nil,
                                         mouseType: clickType,
                                         mouseCursorPosition: flippedPoint,
                                         mouseButton: .left)
                clickEvent?.post(tap: .cghidEventTap)
            }

//            print("🖱️ Double clicked after restore at (unflipped): \(point), actual: \(flippedPoint)")
        }

    private func screenContaining(_ point: CGPoint) -> NSScreen? {
        return NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }

    private func flipPointVertically(_ point: CGPoint, on screen: NSScreen) -> CGPoint {
        return CGPoint(x: point.x, y: screen.frame.maxY - point.y)
    }


    func waitForMouseIdleThen(delay: TimeInterval = 1.0, _ action: @escaping () -> Void) {
        let threshold: TimeInterval = 0.3
        var lastMove = Date()
        var monitor: Any?

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
            lastMove = Date()
            print("🖱️ Mouse moved — resetting idle timer")
        }

        DispatchQueue.global().async {
            while Date().timeIntervalSince(lastMove) < threshold {
                usleep(100_000)
            }

            print("💤 Mouse idle. Waiting \(delay)s before clicking...")
            Thread.sleep(forTimeInterval: delay)

            DispatchQueue.main.async {
                if let m = monitor {
                    NSEvent.removeMonitor(m)
                }
                print("🚀 Executing click after smart delay")
                action()
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
                self?.errorMessage = nil   // ✅ Clear error once target is chosen
                print("✅ Target set at: \(location)")

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
