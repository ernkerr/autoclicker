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
        guard let point = targetPoint else {
            print("❌ No target point selected.")
            isRunning = false
            return
        }

        clickCount = 0
        let delay = isIntervalMode ? interval : 1.0 / clicksPerSecond

        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.performClick(at: point)
            self.clickCount += 1
            self.progress = Double(self.clickCount) / Double(self.maxClicks)

            if self.clickCount >= self.maxClicks {
                self.stopClicking()
            }
        }

        print("🟢 Started clicking at \(point), interval: \(delay)s")
    }

    func stopClicking() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        progress = 0
        clickCount = 0
        print("🔴 Stopped clicking")
    }

    func performClick(at point: CGPoint) {
        let originalLocation = NSEvent.mouseLocation

        let clickAction = {
            self.moveCursorAndClick(at: point)
            self.restoreCursor(to: originalLocation)
        }

        if isSmartDelayEnabled {
            waitForMouseIdleThen(clickAction)
        } else {
            clickAction()
        }
    }

    func moveCursorAndClick(at point: CGPoint) {
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedPoint = CGPoint(x: point.x, y: screenHeight - point.y)

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

        print("🖱️ Double clicked at (unflipped): \(point), actual: \(flippedPoint)")
    }

    func restoreCursor(to point: CGPoint) {
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedPoint = CGPoint(x: point.x, y: screenHeight - point.y)

        let moveEvent = CGEvent(mouseEventSource: nil,
                                mouseType: .mouseMoved,
                                mouseCursorPosition: flippedPoint,
                                mouseButton: .left)
        moveEvent?.post(tap: .cghidEventTap)
    }

    func waitForMouseIdleThen(_ action: @escaping () -> Void) {
        let threshold: TimeInterval = 1.2
        var lastMove = Date()
        var monitor: Any?

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
            lastMove = Date()
        }

        DispatchQueue.global().async {
            while Date().timeIntervalSince(lastMove) < threshold {
                usleep(200_000) // 0.2s
            }

            DispatchQueue.main.async {
                if let m = monitor {
                    NSEvent.removeMonitor(m)
                }
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
