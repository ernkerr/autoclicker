//
//  ClickController.swift
//  AutoClicker
//
//  Created by Erin on 7/18/25.
//

import Foundation
import Combine
import AppKit
import AVFoundation // For audio feedback
import ApplicationServices // For accessibility APIs
import QuartzCore // For visual animations

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
    @Published var isAudioFeedbackEnabled: Bool = false
    @Published var isVisualFeedbackEnabled: Bool = false
    @Published var accessibilityMode: Bool = false { // New: Enhanced mode for users with disabilities
        didSet {
            if accessibilityMode {
                // Auto-enable audio and visual feedback when Enhanced Accessibility Mode is turned on
                isAudioFeedbackEnabled = true
                isVisualFeedbackEnabled = true
                print("♿ Enhanced Accessibility Mode activated - Auto-enabled Audio and Visual Feedback")
            } else {
                // Auto-disable audio and visual feedback when Enhanced Accessibility Mode is turned off
                isAudioFeedbackEnabled = false
                isVisualFeedbackEnabled = false
                print("♿ Enhanced Accessibility Mode deactivated - Auto-disabled Audio and Visual Feedback")
            }
        }
    }
    @Published var isTargetSelectionMode: Bool = false // New: Track target selection state
    @Published var smartMode: Bool = false { // New: Smart mode for enhanced features
        didSet {
            if smartMode {
                // Auto-enable smart features when Smart Mode is turned on
                isDoubleClickEnabled = true
                isSmartDelayEnabled = true
                print("🧠 Smart Mode activated - Auto-enabled Double Click and Smart Delay")
            } else {
                // Auto-disable audio and visual feedback when Smart Mode is turned off
                isDoubleClickEnabled = false
                isSmartDelayEnabled = false
                // Note: We don't auto-disable Double Click and Smart Delay
                // This gives users flexibility to keep individual features enabled
                print("🧠 Smart Mode deactivated - Auto-disabled Audio and Visual Feedback")
            }
            // Note: We don't auto-disable when Smart Mode is turned off
            // This gives users flexibility to keep individual features enabled
        }
    }

    
    // Visual feedback overlay window
    private var feedbackWindow: NSWindow?


    private var timer: Timer?
    private var clickCount = 0
    private var targetPoint: CGPoint?
    private var globalMonitor: Any?
    private var delay: TimeInterval = 1 // how long between clicks (seconds)
    private var audioPlayer: AVAudioPlayer? // For accessibility audio feedback
    private var lastClickTime: Date?

    private init() {
        setupAudioFeedback()
    }

    // MARK: - Accessibility Features
    private func setupAudioFeedback() {
        // Using system sounds - no setup needed
    }
    
    private func showAccessibilityPermissionDialog() {
        let alert = NSAlert()
        alert.messageText = "SmartClick Needs Accessibility Permission"
        alert.informativeText = "SmartClick is an assistive technology that helps reduce repetitive strain by automating clicks. To function properly, it needs accessibility permissions.\n\nThis allows SmartClick to:\n• Simulate mouse clicks for assistive automation\n• Provide visual and audio feedback for accessibility\n• Help users with repetitive tasks and strain reduction"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Try to prompt for permissions and open System Preferences
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
            
            // Also try to open System Preferences directly to Accessibility
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func playClickSound() {
        guard isAudioFeedbackEnabled else { return }
        
        // Play sound immediately with no async dispatch for better timing
        if let sound = NSSound(named: "Tink") {
            sound.volume = 0.4
            let played = sound.play()
            print("🔊 Playing Tink sound: \(played ? "Success" : "Failed")")
        } else if let sound = NSSound(named: "Pop") {
            sound.volume = 0.4
            let played = sound.play()
            print("🔊 Playing Pop sound: \(played ? "Success" : "Failed")")
        } else {
            // Fallback to system beep
            NSSound.beep()
            print("🔊 Playing system beep")
        }
    }
    
    private func showVisualFeedback(at point: CGPoint) {
        guard isVisualFeedbackEnabled else { return }
        
        print("👀 Creating visual feedback at: \(point)")
        
        // Create feedback immediately on main thread
        DispatchQueue.main.async { [weak self] in
            self?.createVisualFeedbackCircle(at: point)
        }
    }
    
    private func createVisualFeedbackCircle(at point: CGPoint) {
        // Clean up existing feedback first
        if let existingWindow = feedbackWindow {
            existingWindow.close()
            feedbackWindow = nil
        }
        
        // Add error handling and validation
        guard point.x >= 0 && point.y >= 0 else {
            print("⚠️ Invalid point for visual feedback: \(point)")
            return
        }
        
        // Create a simple, reliable circle
        let size: CGFloat = 50
        let rect = NSRect(
            x: point.x - size/2,
            y: point.y - size/2,
            width: size,
            height: size
        )
        
        // Create window with proper memory management
        let window = NSWindow(
            contentRect: rect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        // Configure window for reliability
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Create simple circle view with proper retain behavior
        let circle = NSView(frame: NSRect(x: 0, y: 0, width: size, height: size))
        circle.wantsLayer = true
        
        let layer = CALayer()
        layer.frame = circle.bounds
        layer.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.7).cgColor
        layer.cornerRadius = size / 2
        circle.layer = layer
        
        window.contentView = circle
        
        // Show window and store reference
        window.orderFront(nil)
        feedbackWindow = window
        print("👀 Visual feedback shown successfully")
        
        // Simple fade out without complex animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if let feedbackWindow = self?.feedbackWindow, feedbackWindow == window {
                feedbackWindow.orderOut(nil)
                self?.feedbackWindow = nil
                print("👀 Visual feedback removed")
            }
        }
    }

    func toggleClicking() {
        // Enhanced accessibility logging
        let action = isRunning ? "Stopping" : "Starting"
        print("🔄 \(action) SmartClick - Assistive clicking mode")
        
        isRunning.toggle()
        isRunning ? startClicking() : stopClicking()
        
        // Notify status bar to update icon
        NotificationCenter.default.post(name: NSNotification.Name("ClickingStateChanged"), object: nil)
    }

    func startClicking() {
        guard let point = targetPoint else {
            print("❌ No target point selected.")
            errorMessage = "No target selected"
            isRunning = false
            return
        }
        
        // Check accessibility permissions
        let trusted = AXIsProcessTrusted()
        if !trusted {
            // Show a user-friendly dialog requesting accessibility permissions
            DispatchQueue.main.async {
                self.showAccessibilityPermissionDialog()
            }
            isRunning = false
            return
        }

        clickCount = 0
        delay = isIntervalMode ? interval : 1.0 / clicksPerSecond
        lastClickTime = Date()
        progress = 0
        
        // Enhanced logging for assistive use
        print("🌟 SmartClick: Starting assistive clicking at \(point)")
        print("🕰️ Interval: \(delay)s, Smart Delay: \(isSmartDelayEnabled ? "ON" : "OFF")")
        if accessibilityMode {
            print("♿ Accessibility mode enabled - Enhanced feedback active")
        }

        // Timer to perform clicks at fixed intervals
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.performClick(at: point)
            
            if self.isClickLimitEnabled && self.clickCount >= self.maxClicks {
                self.stopClicking()
            }
        }

        print("👍 SmartClick assistive automation started")
    }

    func stopClicking() {
        timer?.invalidate()
        timer = nil
        
        // Clean up visual feedback
        if let window = feedbackWindow {
            window.orderOut(nil)
            feedbackWindow = nil
        }

        isRunning = false
        progress = 0
        
        // Notify status bar to update icon
        NotificationCenter.default.post(name: NSNotification.Name("ClickingStateChanged"), object: nil)
        
        if smartMode || accessibilityMode {
            print("🔴 SmartClick: Stopped - Total clicks: \(clickCount)")
        } else {
            print("🔴 Stopped clicking")
        }
    }


    func performClick(at point: CGPoint) {
        let originalLocation = NSEvent.mouseLocation

        let clickAction = {
            // Play sound and click simultaneously
            self.playClickSound()
            self.moveCursorAndClick(at: point)
            
            // Increment click count
            self.clickCount += 1
            
            // Short delay to ensure system processes the click before moving mouse back
            usleep(20000) // 0.02s
            
            self.restoreCursor(to: originalLocation)
            
            if self.isClickLimitEnabled {
                self.progress = Double(self.clickCount) / Double(self.maxClicks)

                if self.clickCount >= self.maxClicks {
                    self.stopClicking()
                }
            } 
        }

        if isSmartDelayEnabled {
            waitForMouseIdleThen(delay: 1.0, clickAction)
        } else {
            clickAction()
        }
    }

    func moveCursorAndClick(at point: CGPoint) {
        let flippedPoint = flipPointVertically(point)

        let moveEvent = CGEvent(mouseEventSource: nil,
                                mouseType: .mouseMoved,
                                mouseCursorPosition: flippedPoint,
                                mouseButton: .left)
        moveEvent?.post(tap: .cghidEventTap)

        // First Click (Count: 1)
        for clickType in [CGEventType.leftMouseDown, .leftMouseUp] {
            let clickEvent = CGEvent(mouseEventSource: nil,
                                     mouseType: clickType,
                                     mouseCursorPosition: flippedPoint,
                                     mouseButton: .left)
            clickEvent?.setIntegerValueField(.mouseEventClickState, value: 1)
            clickEvent?.post(tap: .cghidEventTap)
        }
        
        // Second Click (Count: 2) - required for macOS to recognize "Double Click"
        if isDoubleClickEnabled {
            print("🖱️ Performing Double Click")
            for clickType in [CGEventType.leftMouseDown, .leftMouseUp] {
                let clickEvent = CGEvent(mouseEventSource: nil,
                                         mouseType: clickType,
                                         mouseCursorPosition: flippedPoint,
                                         mouseButton: .left)
                clickEvent?.setIntegerValueField(.mouseEventClickState, value: 2)
                clickEvent?.post(tap: .cghidEventTap)
            }
        }

//        print("🖱️ Double clicked at (unflipped): \(point), actual: \(flippedPoint)")
    }

    func restoreCursor(to point: CGPoint) {
        // NSEvent.mouseLocation uses AppKit coordinates (bottom-left origin)
        // CGEvent expects screen coordinates (top-left origin)
        // We need to flip the Y coordinate relative to the main screen height
        
        let flippedPoint = flipPointVertically(point)
        
        // Move the cursor back to original position
        let moveEvent = CGEvent(mouseEventSource: nil,
                                mouseType: .mouseMoved,
                                mouseCursorPosition: flippedPoint,
                                mouseButton: .left)
        moveEvent?.post(tap: .cghidEventTap)
        
        
    }

    private func screenContaining(_ point: CGPoint) -> NSScreen? {
        return NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }

    private func flipPointVertically(_ point: CGPoint, on screen: NSScreen? = nil) -> CGPoint {
        // CGEvent coordinates are relative to the *Main Screen's* top-left.
        // NSEvent coordinates are relative to the *Main Screen's* bottom-left.
        // To convert globally, we always flip relative to the Main Screen's height.
        // We ignore the specific 'screen' parameter for the height calculation to ensure global consistency.
        
        let mainScreenHeight = NSScreen.screens.first?.frame.height ?? 1080
        let flippedY = mainScreenHeight - point.y
        let flipped = CGPoint(x: point.x, y: flippedY)
        
        return flipped
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
        print("🎯 SmartClick: Target selection mode - Click anywhere to set assistive clicking location")
        isTargetSelectionMode = true

        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            let location = NSEvent.mouseLocation
            DispatchQueue.main.async {
                self?.targetPoint = location
                self?.isTargetSelectionMode = false
                self?.errorMessage = nil   // ✅ Clear error once target is chosen
                print("✅ SmartClick: Target location set at: \(location)")
                
                // Accessibility feedback
                if self?.accessibilityMode == true {
                    print("♿ Accessibility: Click target confirmed for assistive automation")
                }

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
