

//
//  ContentView.swift
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var clickController = ClickController.shared
    @State private var showSettings = false
    @State private var showingErrorMessage = false

    var body: some View {
        VStack(spacing: 16) {
            // 🎯 Target selector with enhanced glass effect
            HStack {
                Button(action: {
                    clickController.selectTarget()
                    showingErrorMessage = false
                }) {
                    Image(systemName: "scope")
                        .font(.title2)
                        .foregroundColor(.primary) // Apple's adaptive gray
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thickMaterial) // Stronger material for better text contrast
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary) // Apple's adaptive gray
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thickMaterial) // Stronger material for better text contrast
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showSettings) {
                    SettingsView(clickController: clickController)
                }
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
                    .fill(clickController.isRunning ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                            .opacity(0.3) // Light glass overlay
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .foregroundColor(.white) // Keep start button text white for contrast
            .buttonStyle(.plain)
            
            if clickController.isRunning {
                VStack(spacing: 0) {
                    Text("Control + Option + Command + Q")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary) // Apple's secondary gray
                    Text("to stop clicking")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary) // Apple's secondary gray
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thickMaterial) // Stronger material for better text contrast
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                )
            }

            // ➕➖ Rate controls with exact target/settings style
            HStack(spacing: 12) {
                Button("-") {
                    clickController.decreaseRate()
                }
                .font(.title2)
                .foregroundColor(.primary) // Apple's adaptive gray
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thickMaterial) // Stronger material for better text contrast
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .buttonStyle(.plain)

                Text(clickController.isIntervalMode ?
                     "\(Int(clickController.interval))" :
                     "\(Int(clickController.clicksPerSecond))"
                )
                .frame(width: 30)
                .foregroundColor(.primary) // Apple's adaptive gray
                .font(.title2.weight(.medium))

                Button("+") {
                    clickController.increaseRate()
                }
                .font(.title2)
                .foregroundColor(.primary) // Apple's adaptive gray
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thickMaterial) // Stronger material for better text contrast
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
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
            ProgressView(value: clickController.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor)) // Apple's adaptive accent
                .frame(width: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thickMaterial) // Apple's strongest material for best text contrast
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .frame(width: 200)
        .foregroundColor(.primary) // Apple's adaptive gray as default
        .background(Color.clear)
    }
}
