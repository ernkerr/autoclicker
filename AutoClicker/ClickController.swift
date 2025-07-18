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
    private var timer: Timer?
    private var clickCount = 0
    private let maxClicks = 10
    private var targetPoint: CGPoint?

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
            self.click(at: point)
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

    func click(at point: CGPoint) {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        let clickDown = CGEvent(mouseEventSource: eventSource, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let clickUp = CGEvent(mouseEventSource: eventSource, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        clickDown?.post(tap: .cghidEventTap)
        clickUp?.post(tap: .cghidEventTap)
        print("🖱️ Clicked at \(point)")
    }

    func selectTarget() {
        print("🎯 Select target enabled. Click anywhere...")

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            let location = NSEvent.mouseLocation
            DispatchQueue.main.async {
                self?.targetPoint = location
                print("✅ Target set at: \(location)")
            }
        }
    }

    func increaseRate() {
        if isIntervalMode {
            interval += 0.5
        } else {
            clicksPerSecond += 1
        }
    }

    func decreaseRate() {
        if isIntervalMode {
                    // In interval mode, increase the interval up to max 60 seconds
                    if interval < 60 {
                        interval += 1
                    }
                } else {
                    // In clicks per second mode, decrease clicksPerSecond until 1, then switch to interval mode
                    if clicksPerSecond > 1 {
                        clicksPerSecond -= 1
                    } else {
                        isIntervalMode = true
                        interval = 1
                    }
                }
            }
}
