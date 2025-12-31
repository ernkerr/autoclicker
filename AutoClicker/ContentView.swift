

//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var clickController = ClickController.shared
    @State private var showSettings = false
    @State private var showingErrorMessage = false
    @State private var showAccessibilityInfo = false

    var body: some View {
        VStack(spacing: 16) {
            // Accessibility mode indicator
            if clickController.smartMode || clickController.accessibilityMode {
                HStack {
                    Image(systemName: clickController.smartMode ? "brain.head.profile" : "person.badge.plus")
                        .foregroundColor(.blue)
                    Text(clickController.smartMode ? "Smart Mode" : "Assistive Mode")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.blue)
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            // 🎯 Target selector with enhanced glass effect
            HStack {
                Button(action: {
                    clickController.selectTarget()
                    showingErrorMessage = false
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "scope")
                            .font(.title2)
                        if clickController.accessibilityMode {
                            Text("Target")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(.primary) // Apple's adaptive gray
                    .frame(width: 65, height: 55) // Matched middle size with settings button
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.thinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                            .overlay(
                                // Add border when in target selection mode
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.blue, lineWidth: clickController.isTargetSelectionMode ? 2 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: clickController.isTargetSelectionMode)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle()) // Make entire area clickable
                .help("Select where to perform assistive clicking")

                Spacer()

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary) // Apple's adaptive gray
                        .frame(width: 65, height: 55) // Matched middle size with target button
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle()) // Make entire area clickable
                .sheet(isPresented: $showSettings) {
                    SettingsView(clickController: clickController)
                        .interactiveDismissDisabled(false)
                }
                .allowsHitTesting(true) // Ensure the main window can still receive drag events
            }
            .frame(maxWidth: .infinity)

            // ▶️ Start/Stop with enhanced visibility
            Button(clickController.isRunning ? "Stop" : "Start") {
                clickController.toggleClicking()
            }
            .font(.title.weight(.semibold))
            .frame(width: 120, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(clickController.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                            .opacity(0.3) // Light glass overlay
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .foregroundColor(.white) // Keep start button text white for contrast
            .buttonStyle(.plain)
            .help(clickController.isRunning ? "Stop clicking" : "Start clicking at selected location")
            
            if clickController.isRunning {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("⌃⌥⌘Q to stop")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.orange)
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }


            // ➕➖ Rate controls with exact target/settings style
            HStack(spacing: 12) {
                Button(action: {
                    clickController.decreaseRate()
                }) {
                    Text("-")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle()) // Makes the whole 36x36 clickable
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)

                Text(clickController.isIntervalMode ?
                     "\(Int(clickController.interval))" :
                     "\(Int(clickController.clicksPerSecond))"
                )
                .frame(width: 30)
                .foregroundColor(.primary) // Apple's adaptive gray
                .font(.title2.weight(.medium))

                Button(action: {
                    clickController.increaseRate()
                }) {
                    Text("+")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle()) // Makes the whole 36x36 clickable
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 6)
            
            // ⏱️ Mode Label
            let value = Int(clickController.isIntervalMode ? clickController.interval : clickController.clicksPerSecond)

            Text(
                clickController.isIntervalMode
                    ? "every \(value) \(value == 1 ? "second" : "seconds")"
                    : "\(value) \(value == 1 ? "per second" : "per second")"
            )
            .font(.caption.weight(.medium))
            .foregroundColor(.secondary) // Apple's secondary gray
            
            if let error = clickController.errorMessage {
                Text(error)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.pink.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.pink.opacity(0.3), lineWidth: 1)
                            )
                    )
            }

            // 📊 Progress bar with glass container
//            ProgressView(value: clickController.progress)
//                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor)) // Apple's adaptive accent
//                .frame(width: 120)
//                .padding(8)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(.regularMaterial)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(.white.opacity(0.2), lineWidth: 1)
//                        )
//                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
//                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(Color.white.opacity(0.05)) // 🌤️ subtle brightening
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
//                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .frame(width: 200)
        .foregroundColor(.primary) // Apple's adaptive gray as default
//.background(Color.clear)
        
    }
}
